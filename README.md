Purpose:
=========

mod_opensignal sends an API request to OpenSignal to send a push notification when a message is sent to an offline user.

The notification contains the following URI-encoded payload:

```
json
{
      "app_id": "{your OpenSignal app ID}",
      "included_segments": [{the segment which defines the receipien user group}],
      "contents": {"en": "{sender name}: {message}"}
}
```

This is based on the mod_zeropush (https://github.com/ZeroPush/mod_zeropush) extension. ZeroPush is outdated, so OpenSignal is a good alternative to send push notifications for free.

Caveats:
=========

mod_opensignal assumes that you have created segments (broadcast channels) with the user's jabber id that represent the devices you would like to notify.

While registering a device at OpenSignal, you could send a tag (unique ID) to OpenSignal. This tag you could use to filter your segments for the receiver or multi channel group.

Note:
==========

This is tested with ejabberd 2.1.10 on Debian 7.

Installing:
==========

### Build a new version depending by your machine and OS

* Make sure you have erlang installed on the machine you are building from
  * You probably want this to be the same machine you intend to install/run ejabberd on. I'm not sure about the interoperability of ejabberd/erlang versions.
* Open the Emakefile and change `/usr/lib/ejabberd/include/` to the correct path on your machine where include files are
* Run the `./build.sh` to build the `mod_opensignal.beam` file
* Copy the `*.beam` file from the `ebin` directory to the location where the other modules are for your server. For Debian/Ubuntu it is 

```
cp ebin/mod_opensignal.beam /usr/lib/ejabberd/ebin/
```

* Add the configuration from below
 

### OR on Debian 7 - 64 Bit use the one you could found in `ebin` folder

```
cp ebin/debian7_64bit/mod_opensignal.beam /usr/lib/ejabberd/ebin/
```



eJabberd 2.1.10
===

Configuration
---

in `ejabberd.cfg`

```
erlang
{mod_opensignal, [
    {api_key, "{your Rest API key}"},
    {app_id, "{your configured app ID}"},
    {post_url, "https://onesignal.com/api/v1/notifications"}
]}
```

