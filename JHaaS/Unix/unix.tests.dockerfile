FROM jhaas_msmoabs

USER ${NB_UID}
COPY unix.tests.make makefile

#RUN make -f ~/unix.tests.make test_unix
