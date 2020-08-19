ich
===

This is an incredibly quick reimplementation of `icanhazip <https://github.com/major/icanhaz>`_ in C.
For the moment, it only supports the ``ip`` functionality, none of the rest (though adding many of the services, if not all of them, would not be terribly difficult).

This is, honestly, quite a lot to have just to support such a simple service.
All the supporting files are present only to make smooth deployment of this service with reasonable security configuration as easy as possible.

The Stack
---------

* `lwan <https://lwan.ws/>`_ - used as a library to build the webserver and page logic
* `hitch <https://hitch-tls.org/>`_ - TLS-terminating proxy server
* `uacme <https://github.com/ndilieto/uacme/>`_ - an ACME-protocol client for TLS Cert renewal

All running on Arch Linux using `nftables <https://netfilter.org/projects/nftables/>`_ for traffic redirection and forwarding
``hitch`` and ``nftables`` are optional; but if you want the simplest configuration, example configurations are provided in ``./cfg``.

Traffic Redirection and Forwarding
----------------------------------

lwan does not officially support running on an externally-visible port, and it remains the author's express suggestion to not do so.
To bypass this limitation, we leverage hitch to redirect traffic from ``443`` to ``8443`` (where the contentful instance of lwan is running) and back.

Furthermore, to forcibly redirect HTTP to HTTPS, we use nftables to redirect traffic from ``80`` to ``8080``.
Then, a very small instance of lwan is running on port ``8080`` that does nothing but respond to ACME challenge requests and redirect all other traffic to whatever URL is specified in the environment variable ``HOMEPAGE_REDIRECT_TARGET``.

Configuration
-------------

To ensure that the redirector appropriately redirects to the intended URL, add the following line (with the appropriate modifications) using ``systemctl edit``:

.. code::

    Environment=HOMEPAGE_REDIRECT_TARGET='https://domain.tld'

If using ``hitch`` to terminate the TLS-endpoint, the example configuration in ``./cfg`` should have ``domain.tld`` replaced with the appropriate URL for the certificate.
Similarly, ``domain.tld`` (and/or ``server.domain.tld``) sould be replaced with the appropriate domain for the certificate issuance.

Design Characteristics
----------------------

* Secure Header Configuration
* Secure TLS Configuration
* High Performance

