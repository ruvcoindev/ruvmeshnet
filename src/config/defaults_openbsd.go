//go:build openbsd
// +build openbsd

package config

// Sane defaults for the BSD platforms. The "default" options may be
// may be replaced by the running configuration.
func getDefaults() platformDefaultParameters {
	return platformDefaultParameters{
		// Admin
		DefaultAdminListen: "unix:///var/run/ruv.sock",

		// Configuration (used for ruvmeshnetctl)
		DefaultConfigFile: "/etc/ruvmeshnet.conf",

		// Multicast interfaces
		DefaultMulticastInterfaces: []MulticastInterfaceConfig{
			{Regex: ".*", Beacon: true, Listen: true},
		},

		// TUN
		MaximumIfMTU:  16384,
		DefaultIfMTU:  16384,
		DefaultIfName: "tun0",
	}
}
