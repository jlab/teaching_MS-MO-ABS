FROM jhaas_msmoabs

USER ${NB_UID}
COPY tour.tests.make makefile
SHELL ["conda", "run", "-n", "bioinftour", "/bin/bash", "-c"]

#RUN make -f ~/unix.tests.make test_unix
