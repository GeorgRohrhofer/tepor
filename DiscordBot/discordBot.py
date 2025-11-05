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

# Channel ID is provided below in for loop, together with message text
async def send_message(channel_id: int, message: str) -> Optional[discord.Message]:
    channel = client.get_channel(channel_id)
    if channel:
        await channel.send(message)
        return 0
    return 1

# run send_message in for loop, for each channel id that is provided
async def send_to_channels(channel_ids: list[int], message: str):
    await ready_event.wait()

    for channel_id in channel_ids:
        result = await send_message(channel_id, message)
        if result == 0:
            print(f"Message sent to channel {channel_id}")
        else:
            print(f"Failed to send message to channel {channel_id}")

def start_bot(token: str):
    client.run(token)
    