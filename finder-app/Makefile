CC = gcc
GENFLAGS = -Wall -g


default: writer

writer: writer.o
	$(CROSS_COMPILE)$(CC) $(GENFLAGS) $^ -o $@

%.o: %.c
	$(CROSS_COMPILE)$(CC) $(GENFLAGS) -c $<


.PHONY: clean

clean:
	rm -f writer
	rm -f *.o