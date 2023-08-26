#!/bin/bash

# echo "Installation de Gum"
# Debian/Ubuntu

# Installation de Gum (seulement si le fichier charm.gpg n'existe pas)

sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg >> /dev/null
echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | sudo tee /etc/apt/sources.list.d/charm.list 
sudo apt update && sudo apt install gum


# Effacer le terminal
clear

TIME=2
RED=1
GREEN=10
ORANGE=3

gum style \
	--foreground 2 --border-foreground 11 --border double \
	--margin "1 2" --padding "2 4" \
	"    __  __       _    _           ___          __  _      "  \
    "   |  \/  |     | |  | |         | \ \        / / | |     "  \
    "   | \  / |_   _| |__| | ___  ___| |\ \  /\  / /__| |__   "  \
    "   | |\/| | | | |  __  |/ _ \/ __| __\ \/  \/ / _ \ '_ \  "  \
    "   | |  | | |_| | |  | | (_) \__ \ |_ \  /\  /  __/ |_) | "  \
    "   |_|  |_|\__, |_|  |_|\___/|___/\__| \/  \/ \___|_.__/  "  \
    "            __/ |                                         "  \
    "           |___/                                          "  \

myhostweb_data() {
    gum style --foreground 4 "Etape 1 : Mise à jour et installation"
    wait $!

    # 1. Mise à jour d'Ubuntu
    gum spin --title.foreground $ORANGE --title="Mise à jour de linux..." sudo apt update && sudo apt upgrade
    wait $!
    gum style --foreground $GREEN "Mise à jour effectué"

    # 2. Installation de Git
    gum spin --title.foreground $ORANGE --title="Installation de Git..." sudo apt install git
    wait git


    # 3. Installation de Zip
    gum spin --title.foreground $ORANGE --title="Installation de Zip..." sudo apt install zip
    wait zip

    # 4. Vérification de l'existence du répertoire MyHostWeb et suppression si nécessaire
    if [ -d "MyHostWeb" ]; then
        gum spin --title.foreground $ORANGE --title="Répertoire MyHostWeb" sudo mv MyHostWeb Backup
        sudo rm -rf MyHostWeb
    fi

    # 5. Clonage du projet GitHub
    gum spin --title.foreground $ORANGE --title="Clonage du repository Github MyHostWeb..." git clone https://github.com/GSoulat/MyHostWeb.git
    sleep 5

    # 6. Vérification de l'installation de Docker et Docker Compose
    gum spin --title.foreground $ORANGE --title="Installation de docker..." sudo apt install docker.io
    gum spin --title.foreground $ORANGE --title="Démarrage de docker..." sudo systemctl start docker
    wait $!
    gum spin --title.foreground $ORANGE --title="Enable docker..." sudo systemctl enable docker
    wait $!

    
    #7. Vérification de  l'installationd de docker compose

    gum spin --title.foreground $ORANGE --title="Docker Compose installation en cours..." sudo apt install docker-compose
    wait $!
    docker system prune -a -f
    wait $!

    # 8. Création du réseau Docker si ce n'est pas déjà fait
    sudo docker network create myhost_network
    wait $!


    volume_name="myhostweb_data"
    if ! docker volume ls -q | grep -q "^${volume_name}$"; then
        docker volume create myhostweb_data
        wait $!
        if docker volume ls -q | grep -q "^${volume_name}$"; then
            gum style --foreground $GREEN "Le volume myhostweb_data à été crée"
        fi
    else
        gum style --foreground $GREEN "Le volume ${volume_name} exists."
    fi

    # bash MyHostWeb/myhostweb.sh
    
}

bye_data() {
    echo "Bonne journée"
    sleep 60
    clear
}

gum confirm 'Voulez vous installer MyhostWeb ?' && myhostweb_data  --affirmative="Oui" --negative="Non" || bye_data