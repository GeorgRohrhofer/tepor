package main

import (
	"fmt"
	"net/http"
	"os"

	"github.com/bwmarrin/discordgo"
	"github.com/gin-gonic/gin"
)

type Statuscode int

const (
	SUCCESS Statuscode = iota
	UNDEFINED_ERROR
	WRONG_CHANNEL_ERROR
	WRONG_USER_ERROR
	USER_NOT_REACHABLE_ERROR
)

var session *discordgo.Session
var ready = make(chan bool)

type ChannelRequest struct {
	Channels       []string `json:"channels"`
	MessageContent string   `json:"messageContent"`
}

type DirectRequest struct {
	Directs        []string `json:"directs"`
	MessageContent string   `json:"messageContent"`
}

func onReady(s *discordgo.Session, r *discordgo.Ready) {
	fmt.Println("Logged in as", s.State.User.Username)
	close(ready)
}

func sendMessageToChannel(channelID string, message string) Statuscode {
	_, err := session.ChannelMessageSend(channelID, message)
	if err != nil {
		return WRONG_CHANNEL_ERROR
	}
	return SUCCESS
}

func sendToAllChannels(channelIDs []string, message string) Statuscode {

	for _, id := range channelIDs {
		result := sendMessageToChannel(id, message)

		if result == SUCCESS {
			fmt.Println("Message sent to channel", id)
		} else {
			fmt.Println("Failed to send message to channel", id)
			return WRONG_CHANNEL_ERROR
		}
	}

	return SUCCESS
}

func sendMessageToDirect(userID string, message string) Statuscode {

	channel, err := session.UserChannelCreate(userID)
	if err != nil {
		return WRONG_USER_ERROR
	}

	_, err = session.ChannelMessageSend(channel.ID, message)
	if err != nil {
		return USER_NOT_REACHABLE_ERROR
	}

	return SUCCESS
}

func sendToAllDirects(userIDs []string, message string) Statuscode {

	for _, id := range userIDs {
		result := sendMessageToDirect(id, message)

		switch result {
		case SUCCESS:
			fmt.Println("Message sent to user", id)

		case USER_NOT_REACHABLE_ERROR:
			fmt.Println("User not reachable", id)
			return USER_NOT_REACHABLE_ERROR

		default:
			fmt.Println("Failed to send message to user", id)
			return WRONG_USER_ERROR
		}
	}

	return SUCCESS
}

func startBot(token string) error {

	var err error
	session, err = discordgo.New("Bot " + token)
	if err != nil {
		return err
	}

	session.AddHandler(onReady)

	err = session.Open()
	if err != nil {
		return err
	}

	fmt.Println("Discord bot running")
	return nil
}

func startAPI() {

	router := gin.Default()

	router.POST("/message/send/channel", func(c *gin.Context) {

		var req ChannelRequest

		if err := c.ShouldBindJSON(&req); err != nil {
			c.String(http.StatusBadRequest, "Invalid JSON")
			return
		}

		if len(req.Channels) == 0 {
			c.String(http.StatusBadRequest, "Missing channels")
			return
		}

		if req.MessageContent == "" {
			c.String(http.StatusBadRequest, "Missing messageContent")
			return
		}

		result := sendToAllChannels(req.Channels, req.MessageContent)

		switch result {
		case SUCCESS:
			c.String(http.StatusOK, "Success")

		case WRONG_CHANNEL_ERROR:
			c.String(http.StatusBadRequest, "Invalid Channel ID")

		default:
			c.String(http.StatusBadRequest, "Unexpected Failure")
		}

	})

	router.POST("/message/send/direct", func(c *gin.Context) {

		var req DirectRequest

		if err := c.ShouldBindJSON(&req); err != nil {
			c.String(http.StatusBadRequest, "Invalid JSON")
			return
		}

		if len(req.Directs) == 0 {
			c.String(http.StatusBadRequest, "Missing directs")
			return
		}

		if req.MessageContent == "" {
			c.String(http.StatusBadRequest, "Missing messageContent")
			return
		}

		result := sendToAllDirects(req.Directs, req.MessageContent)

		switch result {

		case SUCCESS:
			c.String(http.StatusOK, "Success")

		case WRONG_USER_ERROR:
			c.String(http.StatusBadRequest, "Invalid User ID")

		case USER_NOT_REACHABLE_ERROR:
			c.String(http.StatusBadRequest, "User not reachable")

		default:
			c.String(http.StatusBadRequest, "Unexpected Failure")
		}

	})

	router.Run("0.0.0.0:6969")
}

func main() {

	token := os.Getenv("DISCORD_BOT_TOKEN")

	err := startBot(token)
	if err != nil {
		panic(err)
	}

	<-ready

	go startAPI()

	select {}
}
