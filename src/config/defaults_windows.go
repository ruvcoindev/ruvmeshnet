//go:build windows
// +build windows

package config

// Sane defaults for the Windows platform. The "default" options may be
// may be replaced by the running configuration.
func getDefaults() platformDefaultParameters {
	return platformDefaultParameters{
		// Admin
		DefaultAdminListen: "tcp://localhost:9090",

		// Configuration (used for ruvmeshnetctl)
		DefaultConfigFile: "C:\\Program Files\\Ruvmeshnet\\ruvmeshnet.conf",

		// Multicast interfaces
		DefaultMulticastInterfaces: []MulticastInterfaceConfig{
			{Regex: ".*", Beacon: true, Listen: true},
		},

		// TUN
		MaximumIfMTU:  65535,
		DefaultIfMTU:  65535,
		DefaultIfName: "Ruvmeshnet",
	}
}
