//go:build darwin
// +build darwin

package config

// Sane defaults for the macOS/Darwin platform. The "default" options may be
// may be replaced by the running configuration.
func getDefaults() platformDefaultParameters {
	return platformDefaultParameters{
		// Admin
		DefaultAdminListen: "unix:///var/run/ruv.sock",

		// Configuration (used for ruvmeshnetctl)
		DefaultConfigFile: "/etc/ruvmeshnet.conf",

		// Multicast interfaces
		DefaultMulticastInterfaces: []MulticastInterfaceConfig{
			{Regex: "en.*", Beacon: true, Listen: true},
			{Regex: "bridge.*", Beacon: true, Listen: true},
		},

		// TUN
		MaximumIfMTU:  65535,
		DefaultIfMTU:  65535,
		DefaultIfName: "auto",
	}
}
