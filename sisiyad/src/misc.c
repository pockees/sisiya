#include"misc.h"


/*
  Read "n" bytes from a descriptor.
  Use in place of read() when fd is astream socket.
*/
/* 
  Error    => return value < 0
  EOF      => return value = 0
  Normally => value = number of bytes read.
*/
int readn(int fd, char *ptr, int nbytes)
{
	ssize_t nleft, nread;

	nleft = nbytes;
	while (nleft > 0) {
		nread = read(fd, ptr, nleft);
		if (nread < 0)
			return (nread);	/* error, return < 0 */
		else if (nread == 0)
			break;	/* EOF */
		nleft -= nread;
		ptr += nread;
	}
	return (nbytes - nleft);	/* return >= 0 */
}

/*
  Write "n" bytes to a descriptor.
  Use in place of write() when fd is a stream socket.
*/
/* 
  Error    => return value < 0
  Normally => value = number of bytes written.
*/

int writen(int fd, char *ptr, int nbytes)
{
	ssize_t nleft, nwritten;

	nleft = nbytes;
	while (nleft > 0) {
		nwritten = write(fd, ptr, nleft);
		if (nwritten <= 0)
			return (nwritten);	/* error */
		nleft -= nwritten;
		ptr += nwritten;
	}
	return (nbytes - nleft);	/* return >= 0 */
}

/*
  Read a line from descriptor. Red the line one byte at a time,
  looking for the newline. We store the newline in the buffer,
  then follow it with a null (the same as fgets(3)).
  We return the number of characters up to, but not including,
  the null (the same as strlen(3)).
*/
/* 
  Error    => return value = -1
  EOF      => return value = 0
  Normally => value = number of bytes read.
*/

int readline(int fd, char *ptr, int maxlen)
{
	int n, rc;
	char c;

	for (n = 1; n < maxlen; n++) {
		if ((rc = read(fd, &c, 1)) == 1) {
			*ptr++ = c;
			if (c == '\n')
				break;
		} else if (rc == 0) {
			if (n == 1)
				return (0);	/* EOF, no data read */
			else
				break;
		} else
			return (-1);	/* error */
	}
	*ptr = 0;
	return (n);
}
