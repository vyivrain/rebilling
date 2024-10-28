# Rebilling
This is an interview task

## Installing
1. Install make.
2. Install docker-compose with docker.

## Setting up DB
Create a db in postgresql named "rebill" owned by user "postgres" with password "postres".

Copy `.env.example` file to `.env`.

## Running the project
1. On first try run `make build`.
2. Then run `make up`.

## Overview
There're 3 server instances loading up when the project is started.

*Payment API* - which operates accounts and subscriptions. Contains `POST /paymentIntents/create` endpoint to subtract the amount from account. The amount can't be higher than the subscription's price. There're few helper views -

1. '/' - root view that contains subscriptions and accounts information.
2. '/accounts/new' and '/subscriptions/new' - to create respective subscriptions or accounts.
3. '/payment_intents' - records that're created on each `POST /paymentIntents/create` endpoint call.

*Rebil App* - operates rebills. Used for querying Payment API. There're 2 helper views. '/' - to view rebills records, '/rebill' - to post a charge to `POST /paymentIntents/create` endpoint. Each form request will create a rebill record.
Rebill form uses identifiers from subscription and account to make a charge.

*Rebil Worker* - where the actual work is done. Worker queries every 10 seconds for appropriate rebills and tries to charge the account. And as the task says it tries to charge 4 times. If successful on partial charge, schedules another try after a week.
If charge fails on 4 times or after scheduled, it'll be cancelled.
