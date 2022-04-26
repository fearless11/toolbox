FROM grafana/grafana:6.7.2

WORKDIR /var/lib/grafana/plugins/mongodb-grafana

ADD mongodb-grafana ./

RUN grafana-cli plugins install briangann-datatable-panel \
    && grafana-cli plugins install grafana-piechart-panel \
    && grafana-cli plugins install grafana-worldmap-panel \
    && grafana-cli plugins install farski-blendstat-panel \
    && grafana-cli plugins install agenty-flowcharting-panel \
    && grafana-cli plugins install michaeldmoore-multistat-panel \
    && grafana-cli plugins install smartmakers-trafficlight-panel

