#!/bin/bash
until [ `systemctl is-active docker` == "active" ]; do
    sleep 1
done