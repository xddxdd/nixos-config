import asyncio
import dbm
import os
import threading
from typing import Any, Iterable, Optional

from telethon import TelegramClient, events
from telethon.tl.custom import Message
from telethon.tl.types import PeerChannel, PeerUser

TG_API_ID = int(os.environ["TG_API_ID"])
TG_API_HASH = os.environ["TG_API_HASH"]
DEL_MESSAGE_SECONDS = 15


class LastMessageManager:
    def __init__(self):
        self.db = dbm.open("records.dbm", "c")
        self.db_lock = threading.Lock()
        self.no_delete_set = set()
        self.no_delete_lock = threading.Lock()

    def get(self, channel_id: int, user_id: int) -> list[int]:
        """Get the last message ID, and the last message user replied to.

        Args:
            channel_id (int): _description_
            user_id (int): _description_

        Returns:
            list[int]: Contains 0-2 message IDs that are relevant to the user/channel.
        """
        l = []
        try:
            msg = int(self.db["%d,%d,msg" % (channel_id, user_id)])
            if msg:
                l.append(msg)
            reply = int(self.db["%d,%d,reply" % (channel_id, user_id)])
            if reply:
                l.append(reply)
        except:
            pass

        return l

    def set(
        self, channel_id: int, user_id: int, msg: Optional[int], reply: Optional[int]
    ):
        """Record bot message ID, and the message that is being replied to.

        Args:
            channel_id (int): _description_
            user_id (int): _description_
            msg (Optional[int]): _description_
            reply (Optional[int]): _description_
        """
        msg = msg if msg else 0
        reply = reply if reply else 0
        self.db["%d,%d,msg" % (channel_id, user_id)] = str(msg)
        self.db["%d,%d,reply" % (channel_id, user_id)] = str(reply)

    def clear(self, channel_id: int, user_id: int):
        self.set_last_message(channel_id, user_id, None, None)

    def add_no_delete(self, msg_id: int):
        with self.no_delete_lock:
            self.no_delete_set.add(msg_id)

    def remove_no_delete(self, msg_id: int):
        try:
            self.no_delete_set.remove(msg_id)
        except KeyError:
            pass

    def is_in_no_delete(self, msg_ids: Iterable[int]) -> bool:
        with self.no_delete_lock:
            return bool(self.no_delete_set.intersection(msg_ids))


class MessageHandler:
    def __init__(self, message: Message, last_msg_manager: LastMessageManager):
        self.message = message
        self.last_msg_manager = last_msg_manager

    @property
    def user_id(self) -> int:
        return self.message.from_id.user_id

    @property
    def channel_id(self) -> int:
        return self.message.peer_id.channel_id

    @property
    def msg_id(self) -> int:
        return self.message.id

    @property
    def reply_id(self) -> Optional[int]:
        if self.message.reply_to:
            return self.message.reply_to.reply_to_msg_id
        else:
            return None

    async def get_reply(self) -> Optional[Message]:
        if self.reply_id:
            return await client.get_messages(self.channel_id, ids=self.reply_id)
        else:
            return None

    async def is_replying_command(self) -> bool:
        reply = await self.get_reply()
        return bool(reply and len(reply.message) >= 1 and reply.message[0] in "/\\")

    @property
    def is_sender_bot(self) -> bool:
        return bool(self.message.sender and self.message.sender.bot)

    def log_msg(self, action: str, message_ids: Any = None):
        print(
            f"{action}: bot {self.user_id} msg {message_ids or self.msg_id} channel {self.channel_id} reply to {self.reply_id}"
        )

    def log_reply(self, action: str, reply: Message):
        print(
            f"{action}: user {self.user_id} reply {reply.id} to {reply.from_id.user_id} channel {self.channel_id}"
        )

    async def handle_bot_message(self):
        self.log_msg("New bot message")

        # Record message/reply ID pair, to be deleted when a new message comes
        with self.last_msg_manager.db_lock:
            # Get last recorded message/reply ID pair
            msg_ids = self.last_msg_manager.get(self.channel_id, self.user_id)
            self.last_msg_manager.set(
                self.channel_id, self.user_id, self.msg_id, self.reply_id
            )

        if not msg_ids:
            return
        # Start delete last message/reply messages from the bot after DEL_MESSAGE_SECONDS

        # Check if message is marked as no delete. This can happen if a user replied to bot message
        # and we want to preserve chat context
        no_delete = self.last_msg_manager.is_in_no_delete(msg_ids)
        if no_delete:
            self.log_msg(
                "Messages marked no delete",
                message_ids=",".join([str(i) for i in msg_ids]),
            )
            return

        # Schedule delete message after time period
        self.log_msg("Schedule del", message_ids=",".join([str(i) for i in msg_ids]))
        await asyncio.sleep(DEL_MESSAGE_SECONDS)

        # Check again in case someone replied to bot message during the delay
        no_delete = self.last_msg_manager.is_in_no_delete(msg_ids)
        if no_delete:
            self.log_msg(
                "Messages marked no delete",
                message_ids=",".join([str(i) for i in msg_ids]),
            )
            return

        # Delete
        await client.delete_messages(self.channel_id, msg_ids, revoke=True)
        self.log_msg("Actual del", message_ids=",".join([str(i) for i in msg_ids]))

    async def handle_user_reply(self):
        # Check if user is replying to some message
        reply = await self.get_reply()
        if not reply:
            return
        if not isinstance(reply.from_id, PeerUser):
            return
        if not isinstance(reply.peer_id, PeerChannel):
            return
        # Unlikely: user replied to msg in another channel
        if reply.peer_id.channel_id != self.channel_id:
            return

        # Check if user is replying to a known bot message
        if self.last_msg_manager.is_in_no_delete([reply.id]):
            # User is replying to a known bot message, unschedule that bot message for deletion
            self.log_reply("User reply", reply)
            self.last_msg_manager.clear(self.channel_id, reply.from_id.user_id)

        # Prevent the replied message from being deleted, in case delete is already scheduled
        self.log_reply("Add to no delete", reply)
        self.last_msg_manager.add_no_delete(reply.id)

        await asyncio.sleep(DEL_MESSAGE_SECONDS * 2)

        # Clear the no delete entry after 2x delay, to prevent it from being too big
        self.log_reply("Del from no delete", reply)
        self.last_msg_manager.remove_no_delete(reply.id)

    async def handle(self):
        # Only handle user's message to channels
        if not isinstance(self.message.from_id, PeerUser):
            return
        if not isinstance(self.message.peer_id, PeerChannel):
            return

        # Handle if message is from a bot...
        if self.is_sender_bot or await self.is_replying_command():
            await self.handle_bot_message()
        else:
            await self.handle_user_reply()


last_msg_manager = LastMessageManager()
client: TelegramClient
with TelegramClient("tg", TG_API_ID, TG_API_HASH) as client:

    @client.on(events.NewMessage(incoming=True))
    async def handler(event: events.NewMessage.Event):
        await client.send_read_acknowledge(
            event.message.peer_id,
            event.message,
            clear_mentions=True,
            clear_reactions=True,
        )
        await MessageHandler(event.message, last_msg_manager).handle()

    print("Bot cleaner is up and running")
    client.run_until_disconnected()
