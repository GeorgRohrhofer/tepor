from typing import Optional
import discord
import asyncio

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
        return 0
    return 1

# Sends to given Channels
async def send_to_all_channels(channel_ids: list[int], message: str):
    await ready_event.wait()
    for channel_id in channel_ids:
        result = await _send_message_to_channel(channel_id, message)
        if result == 0:
            print(f"Message sent to channel {channel_id}")
        else:
            print(f"Failed to send message to channel {channel_id}")

# Direct Message to User
# Send Message to User
async def _send_message_to_direct(user_id: int, message: str) -> Optional[discord.Message]:
    try:
        user = await client.fetch_user(user_id) # schauen ob ich await brauche
        if user:
            await user.send(message)
            return 0
        else: 
            return 1
    except discord.Forbidden:
        return 2
    except Exception:
        return 1

# Sends to given Users
async def send_to_all_directs(user_ids: list[int], message: str):
    await ready_event.wait()
    for user_id in user_ids:
        result = await _send_message_to_direct(user_id, message)
        if result == 0:
            print(f"Message sent to user {user_id}")
        elif result == 2:
            print(f"Failed to send message to user {user_id}. Privat Messages are deactivated.")
        else:
            print(f"Failed to send message to user {user_id}")

def start_bot(token: str):
    client.run(token)
