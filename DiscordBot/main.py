from typing import Optional
import discord
import asyncio
import os

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

# simulate external api call
async def simulate_external_trigger():
    print("External trigger received, sending messages...")
    await send_to_channels([123456, 789101112], "Hello from the bot!")

async def main():
    # run bot and simulated external trigger at same time
    await asyncio.gather(
        client.start(os.getenv("DISCORD_BOT_TOKEN")),
        simulate_external_trigger()
    )

if __name__ == "__main__":
    print("test bot")
    asyncio.run(main())
    