# Docker image

## Fetch project and sub projects.

First of all read [Git tools - submodules](https://git-scm.com/book/en/v2/Git-Tools-Submodules).
You must run:

    git submodule update --init --recursive

to initialize your local configuration file and fetch all the data from the sub projects.

## Environment variables

Next, copy .env.example into .env file inside api project and set the environment variables:

    cp api/.env.example api/.env

Also, copy .env.example into .env file on superproject
    
    cp .env.example .env

## Run project

To run project use:

    docker-compose up --build -detach
