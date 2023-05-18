import asyncio
import logging
import os
import smartrent
import time

CHECK_INTERVAL = 120
LOCK_TIMEOUT = 600

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s.%(msecs)03d %(levelname)s %(module)s - %(funcName)s: %(message)s',
    datefmt='%Y-%m-%d %H:%M:%S',
)


async def main():
    api = await smartrent.async_login(os.environ["SMARTRENT_EMAIL"], os.environ["SMARTRENT_PASSWORD"])

    last_unlocked = {}

    while True:
        for lock in api.get_locks():
            lock_id = lock._device_id

            if lock.get_locked():
                logging.info(f"Lock {lock_id} locked")
                last_unlocked.pop(lock_id, None)

            elif lock_id in last_unlocked:
                elapsed = time.time() - last_unlocked[lock_id]
                if elapsed >= 600:
                    logging.info(f"Lock {lock_id} unlocked for {elapsed}s, locking...")
                    last_unlocked.pop(lock_id, None)
                    await lock.async_set_locked(True)

                else:
                    logging.info(f"Lock {lock_id} unlocked for {elapsed}s, waiting...")

            else:
                logging.info(
                    f"Lock {lock_id} unlocked, will lock after {LOCK_TIMEOUT}s")
                last_unlocked[lock_id] = time.time()

        time.sleep(CHECK_INTERVAL)

asyncio.run(main())
