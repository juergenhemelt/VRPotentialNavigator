FROM rocker/shiny:3.4.4

WORKDIR /VRPN

COPY r_packages.R /VRPN/
RUN Rscript r_packages.R

COPY *.R /VRPN/
COPY *.csv /VRPN/
COPY www/* /VRPN/www/

EXPOSE 5060/tcp

CMD Rscript run.R


