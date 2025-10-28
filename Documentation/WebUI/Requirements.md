# Frontend Requirements – V1

## Roles

- **User**  
  - Can create new worlds  
  - Can edit their own worlds  

- **Admins (one or more)**  
  - View server node and world distribution  
  - View detailed server node information  

---

## Authentication Page

- Login via **Keycloak** options:  
  - **Google Account**  
  - **Microsoft Account**  

---

## Worlds Overview Page

Displays all available worlds in a list view with the following features:

- **Download** world  
- **Upload** world (`.zip` format)  
- **Create**, **Edit**, and **Delete** worlds  
- Show **Creator** name  
- Show **Last Updated / Status**

---

## World Creation

Form for creating a new world with the following inputs:

- **World Name**  
- **World Seed**  
- **Expert Options** – allows editing of world configuration file 
- **World Configuration** (Template-based text field) including:  
  - World Type (e.g., *Superflat*, *Infinity*, *Greater Biomes*, etc.)  
  - Whitelist settings  
  - Commands  
  - Player Mode (Creative, Survival, Adventure)  
  - Mob Griefing, and other parameters  

---

## World Editing

- Editable **World Configuration** textbox  
- Allows full manual modification of the world configuration  

---

## World Deletion

- Confirmation page with:  
  - “Are you sure?” prompt  
  - Textbox requiring re-entry of the world name for confirmation  
- Option to **download the world** before deletion  

---

## Server Node – Worlds Interface

Displays two linked lists:

1. **Left list:** Available Server Nodes  
2. **Right list:** Worlds assigned to the selected node  

Selecting a world in the right list opens its **World Configuration** page.

---

## Server Node – Information Interface

Displays live monitoring information for each server node:

- CPU usage  
- GPU usage  
- Storage capacity  
- Internet connection details (Ping, Speed, etc.)  
- Automatic refresh every **5 seconds** (from backend monitoring service)  
- Optional: Graphical visualization of performance metrics  

---

## User Management

Admin functions for user control:

- **Block users**  
- View which worlds a user has created  
- **Delete user accounts**

---

## Discord Bot Configuration

- Manage **Channel ID List** for bot integration
