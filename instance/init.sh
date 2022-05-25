#!/usr/bin/env bash

prep_system() {
    DEBIAN_FRONTEND=noninteractive apt-get -qqy update
    DEBIAN_FRONTEND=noninteractive apt-get -qqy -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold' upgrade
    DEBIAN_FRONTEND=noninteractive apt-get -qqy -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold' install linux-headers-$(uname -r) python3-apt python3-pip curl wget unzip jq wireguard resolvconf
}

add_monitoring() {
    curl -sL https://ibm.biz/install-sysdig-agent | bash -s -- -a b21db43b-c518-4919-b188-5ff455623ceb -c ingest.private.ca-tor.monitoring.cloud.ibm.com --collector_port 6443 --tags "host:$(hostname -s)" --secure true -ac "sysdig_capture_enabled: false"
}

add_logging() {
    echo "deb https://repo.logdna.com stable main" | tee /etc/apt/sources.list.d/logdna.list
    wget -O- https://repo.logdna.com/logdna.gpg | apt-key add -
    DEBIAN_FRONTEND=noninteractive apt-get -qqy update
    DEBIAN_FRONTEND=noninteractive apt-get install logdna-agent < "/dev/null"
    logdna-agent -k fc4fa5710ebd9522282a064102a00c6a
    logdna-agent -s LOGDNA_APIHOST=api.ca-tor.logging.cloud.ibm.com
    logdna-agent -t "host:$(hostname -s)"
    logdna-agent -d /opt/draios/logs/
    systemctl enable --now logdna-agent
}



prep_system
add_monitoring
add_logging
