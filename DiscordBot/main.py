from flask import Flask, jsonify, request, render_template
from flask_cors import CORS
import discordBot as dbot
from threading import Thread
import os
import asyncio

app = Flask(__name__)
CORS(app)

def start_api():
    app.run(host="0.0.0.0", port=6969)

@app.post("/message/send/channel")
def messageSendToChannels():
    jdata = request.get_json()  
    if not jdata:
        return "Invalid or empty JSON body", 400

    channels = jdata.get("channels")
    message = jdata.get("messageContent")

    if not isinstance(channels, list) or len(channels) == 0:
        return "Missing or invalid 'channels' array", 400
    if not isinstance(message, str) or not message.strip():
        return "Missing or empty 'messageContent'", 400
    
    future = asyncio.run_coroutine_threadsafe(
        dbot.send_to_all_channels(jdata["channels"], jdata["messageContent"]),
        dbot.client.loop
    )
    result = future.result(timeout=10)

    if (result == dbot.Statuscode.SUCCESS):
        return "Success", 200
    if (result == dbot.Statuscode.WRONG_CHANNEL_ERROR):
        return "Invalid Channel ID", 400
    return "Unexpected Failure", 400
    
@app.post("/message/send/direct")
def messageSendToDirects():
    jdata = request.get_json()    
    if not jdata:
        return "Invalid or empty JSON body", 400
    
    directs = jdata.get("channels")
    message = jdata.get("messageContent")

    if not isinstance(directs, list) or len(directs) == 0:
        return "Missing or invalid 'directs' array", 400
    if not isinstance(message, str) or not message.strip():
        return "Missing or empty 'messageContent'", 400

    future = asyncio.run_coroutine_threadsafe(
        dbot.send_to_all_directs(jdata["directs"], jdata["messageContent"]),
        dbot.client.loop
    )
    result = future.result(timeout=10)

    if (result == dbot.Statuscode.SUCCESS):
        return "Success", 200
    if (result == dbot.Statuscode.WRONG_USER_ERROR):
        return "Invalid User ID", 400
    if (result == dbot.Statuscode.USER_NOT_REACHABLE_ERROR):
        return "User not reachable", 400
    return "Unexpected Failure", 400

if __name__ == "__main__":
    flask_thread = Thread(target=start_api)
    flask_thread.daemon=True
    flask_thread.start()
    dbot.start_bot(os.getenv("DISCORD_BOT_TOKEN"))
    