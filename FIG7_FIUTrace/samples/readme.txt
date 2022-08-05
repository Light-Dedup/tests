This README file was adapted from:

 http://sylab-srv.cs.fiu.edu/doku.php?id=projects:iodedup:start

3 weeks of traces collected during the period 11/01/08-11/21/08. All
the systems were running Linux using the ext3 file system.

Files 	                        Description
mail.tar.xz (LZMA compression)	CS department's mail server traces. It
                                includes all the inboxes of mails in
				the CS department.
homes.tar.gz 	                Research group activities: developing,
                                testing, experiments, technical
				writing, plotting.
web-vm.tar.gz 	                CS department webmail proxy and online
course management.

The traces files (one per day) are in ASCII and each record is as follows:

    [ts in ns] [pid] [process] [lba] [size in 512 Bytes blocks] [Write or Read] [major device number] [minor device number] [MD5 per 4096 Bytes]

In the case of the homes traces, the format is different for the digests:

    [ts in ns] [pid] [process] [lba] [size in 512 Bytes blocks] [Write or Read] [major device number] [minor device number] [MD5 per 512 Bytes]
