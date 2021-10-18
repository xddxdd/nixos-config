from telethon import TelegramClient, events
from telethon.tl.types import PeerChannel, PeerUser
import dbm
import os
import threading
import asyncio

api_id = int(os.environ.get('TG_API_ID'))
api_hash = os.environ.get('TG_API_HASH')

DEL_MESSAGE_SECONDS = 15

db = dbm.open('records.dbm', 'c')
db_lock = threading.Lock()


def get_last_message(channel_id, user_id):
    l = []
    try:
        msg = int(db['%d,%d,msg' % (channel_id, user_id)])
        if msg:
            l.append(msg)
        reply = int(db['%d,%d,reply' % (channel_id, user_id)])
        if reply:
            l.append(reply)
    except:
        pass

    return l


def set_last_message(channel_id, user_id, msg, reply):
    msg = msg if msg else 0
    reply = reply if reply else 0
    db['%d,%d,msg' % (channel_id, user_id)] = str(msg)
    db['%d,%d,reply' % (channel_id, user_id)] = str(reply)


no_delete_set = set()
no_delete_lock = threading.Lock()

with TelegramClient('tg', api_id, api_hash) as client:
    @client.on(events.NewMessage())
    async def handler(event):
        await client.send_read_acknowledge(event.message.peer_id, event.message, clear_mentions=True)

        # Only handle user's message to channels
        if not isinstance(event.message.from_id, PeerUser):
            return
        if not isinstance(event.message.peer_id, PeerChannel):
            return

        # Only handle replies
        if not event.message.reply_to:
            return

        user_id = event.message.from_id.user_id
        channel_id = event.message.peer_id.channel_id
        msg_id = event.message.id
        reply_id = event.message.reply_to.reply_to_msg_id

        reply = await client.get_messages(channel_id, ids=reply_id)

        # Handle if replying to a message starting with / ...
        if reply and len(reply.message) >= 1 and reply.message[0] == '/':
            print('Bot %d new msg %d channel %d reply to %d' %
                  (user_id, msg_id, channel_id, reply_id))

            with db_lock:
                l = get_last_message(channel_id, user_id)
                set_last_message(channel_id, user_id, msg_id, reply_id)

            if l:
                print('Schedule del bot %d channel %d msg %s' %
                      (user_id, channel_id, ','.join([str(i) for i in l])))
                await asyncio.sleep(DEL_MESSAGE_SECONDS)

                # It's possible that user wants to keep the message after deletion is scheduled
                no_delete = False
                with no_delete_lock:
                    for id in l:
                        if id in no_delete_set:
                            no_delete = True
                            break

                if not no_delete:
                    await client.delete_messages(channel_id, l, revoke=True)
                    print('Actual del bot %d channel %d msg %s' %
                          (user_id, channel_id, ','.join([str(i) for i in l])))
        else:
            # Check if user is replying to a known bot message
            if not isinstance(reply.from_id, PeerUser):
                return
            if not isinstance(reply.peer_id, PeerChannel):
                return
            # Unlikely: user replied to msg in another channel
            if reply.peer_id.channel_id != channel_id:
                return

            # Do not remove if a bot message is replied to
            with db_lock:
                l = get_last_message(channel_id, reply.from_id.user_id)
                if reply.id in l:
                    # User is replying to a known bot message
                    print('User %d reply %d to bot %d channel %d' %
                          (user_id, reply.id, reply.from_id.user_id, channel_id))
                    set_last_message(channel_id, reply.from_id.user_id, 0, 0)

            print('Add msg %d to no_delete set' % (reply.id))
            with no_delete_lock:
                no_delete_set.add(reply.id)

            await asyncio.sleep(DEL_MESSAGE_SECONDS)

            print('Del msg %d from no_delete set' % (reply.id))
            with no_delete_lock:
                no_delete_set.remove(reply.id)

    print('Bot cleaner is up and running')
    client.run_until_disconnected()
