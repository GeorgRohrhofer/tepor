from typing import Optional
import discord
import asyncio
from enum import Enum

intents = discord.Intents.default()
client = discord.Client(intents=intents)
ready_event = asyncio.Event()

@client.event
async def on_ready():
    print(f'We have logged in as {client.user}')
    ready_event.set()

# Message to Server Channel
# Send Message to Server Channel
async def _send_message_to_channel(channel_id: int, message: str) -> Optional[discord.Message]:
    channel = client.get_channel(channel_id)
    if channel:
        await channel.send(message)
        return Statuscode.SUCCESS
    return Statuscode.WRONG_CHANNEL_ERROR

# Sends to given Channels
async def send_to_all_channels(channel_ids: list[int], message: str):
    await ready_event.wait()
    for channel_id in channel_ids:
        result = await _send_message_to_channel(channel_id, message)
        if result == Statuscode.SUCCESS:
            print(f"Message sent to channel {channel_id}")
        else:
            print(f"Failed to send message to channel {channel_id}")
    return Statuscode.SUCCESS

# Direct Message to User
# Send Message to User
async def _send_message_to_direct(user_id: int, message: str) -> Optional[discord.Message]:
    try:
        user = await client.fetch_user(user_id) 
        if user:
            await user.send(message)
            return Statuscode.SUCCESS
        else: 
            return Statuscode.UNDIFINED_ERROR
    except discord.Forbidden:
        return Statuscode.USER_NOT_REACHABLE_ERROR
    except Exception:
        return Statuscode.WRONG_USER_ERROR

# Sends to given Users
async def send_to_all_directs(user_ids: list[int], message: str):
    await ready_event.wait()
    for user_id in user_ids:
        result = await _send_message_to_direct(user_id, message)
        if result == Statuscode.SUCCESS:
            print(f"Message sent to user {user_id}")
        elif result == Statuscode.USER_NOT_REACHABLE_ERROR:
            print(f"Failed to send message to user {user_id}. Privat Messages are deactivated.")
        else:
            print(f"Failed to send message to user {user_id}")
    return Statuscode.SUCCESS

class Statuscode(Enum):
    SUCCESS = 0
    UNDIFINED_ERROR = 1
    WRONG_CHANNEL_ERROR = 2
    WRONG_USER_ERROR = 3
    USER_NOT_REACHABLE_ERROR = 4

def start_bot(token: str):
    client.run(token)
