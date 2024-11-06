#!/bin/bash

mv /localAssets/assets/manager002/* /web/html/
rc-service apache2 start
rc-update add apache2