package main

import (
	"flag"
	"fmt"
	"os"
	"strings"

	tasagent "github.com/trungtran/tas-agent"
	"github.com/trungtran/tas-agent/internal/installer"
	"github.com/trungtran/tas-agent/internal/profiles"
	"github.com/trungtran/tas-agent/internal/updater"
	"github.com/trungtran/tas-agent/internal/version"
)

const usage = `tas-agent — Install AI agent skills, rules, and workflows into your project.

USAGE:
  tas-agent <command> [flags]

COMMANDS:
  install <profile>   Install skills and rules for a profile
  update [profile]    Re-install / update skills (force overwrite)
  list [profile]      List available profiles and skills
  version             Show version information
  check-update        Check for a new CLI version on GitHub
  self-update         Download and replace with the latest CLI version

INSTALL / UPDATE FLAGS:
  --target, -t <dir>  Target directory (default: current directory)
  --force, -f         Overwrite existing files (install only)
  --dry-run           Show what would be changed without modifying files

PROFILES:
  be         Backend (NestJS, Java, Go, Python, Rust, C, Dart)
  fe         Frontend (React, Next.js, Vue, Svelte, React Native)
  fullstack  Full-stack (backend + frontend)
  all        Everything

  Individual skills can also be used:
    tas-agent install golang
    tas-agent update nestjs

EXAMPLES:
  tas-agent install be
  tas-agent install fe --target ./my-project
  tas-agent update                  # re-installs using last profile from manifest
  tas-agent update be --dry-run
  tas-agent list
  tas-agent check-update
  tas-agent self-update
`

func main() {
	if len(os.Args) < 2 {
		fmt.Print(usage)
		os.Exit(1)
	}

	cmd := os.Args[1]
	switch cmd {
	case "install":
		runInstall(os.Args[2:])
	case "update":
		runUpdate(os.Args[2:])
	case "list":
		runList(os.Args[2:])
	case "version", "--version", "-v":
		printVersion()
	case "check-update":
		runCheckUpdate()
	case "self-update":
		runSelfUpdate()
	case "help", "--help", "-h":
		fmt.Print(usage)
	default:
		fmt.Fprintf(os.Stderr, "Error: unknown command %q\n\n", cmd)
		fmt.Print(usage)
		os.Exit(1)
	}
}

// ── version ──────────────────────────────────────────────────────────────────

func printVersion() {
	fmt.Printf("tas-agent %s\n", version.Version)
	fmt.Printf("  commit:     %s\n", version.Commit)
	fmt.Printf("  build date: %s\n", version.BuildDate)
	fmt.Printf("  releases:   %s\n", version.GitHubReleasesURL())
}

// ── check-update ─────────────────────────────────────────────────────────────

func runCheckUpdate() {
	fmt.Printf("Checking for updates (current: %s)...\n", version.Version)
	release, err := updater.CheckLatestRelease()
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error: %v\n", err)
		os.Exit(1)
	}

	latest := release.TagName
	if updater.IsNewer(version.Version, latest) {
		fmt.Printf("\n✓ New version available: %s → %s\n", version.Version, latest)
		fmt.Printf("  Run 'tas-agent self-update' to upgrade.\n")
		fmt.Printf("  Or download manually: %s\n", release.HTMLURL)
	} else {
		fmt.Printf("✓ You are up to date (%s)\n", version.Version)
	}
}

// ── self-update ───────────────────────────────────────────────────────────────

func runSelfUpdate() {
	fmt.Printf("Checking for updates (current: %s)...\n", version.Version)
	release, err := updater.CheckLatestRelease()
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error: %v\n", err)
		os.Exit(1)
	}

	latest := release.TagName
	if !updater.IsNewer(version.Version, latest) {
		fmt.Printf("✓ Already up to date (%s)\n", version.Version)
		return
	}

	fmt.Printf("New version: %s → %s\n", version.Version, latest)

	asset, ok := updater.FindAsset(release)
	if !ok {
		fmt.Fprintf(os.Stderr,
			"Error: no binary found for your platform (%s)\n"+
				"Download manually: %s\n",
			updater.CurrentPlatformAsset(), release.HTMLURL)
		os.Exit(1)
	}

	if err := updater.SelfUpdate(asset); err != nil {
		fmt.Fprintf(os.Stderr, "Error: %v\n", err)
		os.Exit(1)
	}
	fmt.Printf("✓ Updated to %s. Run 'tas-agent version' to verify.\n", latest)
}

// ── install ───────────────────────────────────────────────────────────────────

func runInstall(args []string) {
	fs := flag.NewFlagSet("install", flag.ExitOnError)
	target := fs.String("target", "", "Target directory (default: current directory)")
	fs.StringVar(target, "t", "", "Target directory (shorthand)")
	force := fs.Bool("force", false, "Overwrite existing files")
	fs.BoolVar(force, "f", false, "Overwrite existing files (shorthand)")
	dryRun := fs.Bool("dry-run", false, "Show what would be installed without making changes")

	fs.Usage = func() {
		fmt.Fprintln(os.Stderr, "Usage: tas-agent install <profile> [flags]")
		fs.PrintDefaults()
	}

	if len(args) < 1 || strings.HasPrefix(args[0], "-") {
		fmt.Fprintln(os.Stderr, "Error: profile argument required\n")
		fmt.Fprintln(os.Stderr, "Usage: tas-agent install <profile> [flags]")
		fmt.Fprintln(os.Stderr, "Run 'tas-agent list' to see available profiles")
		os.Exit(1)
	}
	profileName := args[0]

	if err := fs.Parse(args[1:]); err != nil {
		os.Exit(1)
	}

	targetDir := resolveTargetDir(*target)
	profile, err := profiles.Get(profileName)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error: %v\n", err)
		os.Exit(1)
	}

	opts := installer.Options{DryRun: *dryRun, Force: *force}
	if err := installer.Install(tasagent.AgentFS, profile, targetDir, opts); err != nil {
		fmt.Fprintf(os.Stderr, "Error: %v\n", err)
		os.Exit(1)
	}
}

// ── update ────────────────────────────────────────────────────────────────────

func runUpdate(args []string) {
	fs := flag.NewFlagSet("update", flag.ExitOnError)
	target := fs.String("target", "", "Target directory (default: current directory)")
	fs.StringVar(target, "t", "", "Target directory (shorthand)")
	dryRun := fs.Bool("dry-run", false, "Show what would be updated without making changes")

	fs.Usage = func() {
		fmt.Fprintln(os.Stderr, "Usage: tas-agent update [profile] [flags]")
		fs.PrintDefaults()
	}

	// Profile is optional for update — read from manifest if omitted
	var profileName string
	if len(args) > 0 && !strings.HasPrefix(args[0], "-") {
		profileName = args[0]
		args = args[1:]
	}

	if err := fs.Parse(args); err != nil {
		os.Exit(1)
	}

	targetDir := resolveTargetDir(*target)

	if profileName == "" {
		// Read profile from manifest
		manifest, err := installer.ReadManifest(targetDir)
		if err != nil {
			fmt.Fprintf(os.Stderr,
				"Error: no profile specified and no manifest found in %s\n"+
					"Run 'tas-agent install <profile>' first, or specify a profile: tas-agent update <profile>\n",
				targetDir)
			os.Exit(1)
		}
		profileName = manifest.Profile
		fmt.Printf("Using profile from manifest: %s (installed %s)\n\n",
			manifest.Profile, manifest.InstalledAt.Format("2006-01-02"))
	}

	profile, err := profiles.Get(profileName)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error: %v\n", err)
		os.Exit(1)
	}

	// Update always overwrites
	opts := installer.Options{DryRun: *dryRun, Force: true}
	if err := installer.Install(tasagent.AgentFS, profile, targetDir, opts); err != nil {
		fmt.Fprintf(os.Stderr, "Error: %v\n", err)
		os.Exit(1)
	}
}

// ── list ──────────────────────────────────────────────────────────────────────

func runList(args []string) {
	fs := flag.NewFlagSet("list", flag.ExitOnError)
	if err := fs.Parse(args); err != nil {
		os.Exit(1)
	}

	if fs.NArg() > 0 {
		profile, err := profiles.Get(fs.Arg(0))
		if err != nil {
			fmt.Fprintf(os.Stderr, "Error: %v\n", err)
			os.Exit(1)
		}
		profiles.PrintProfile(profile)
	} else {
		profiles.PrintAll()
	}
}

// ── helpers ───────────────────────────────────────────────────────────────────

func resolveTargetDir(flag string) string {
	if flag != "" {
		return flag
	}
	dir, err := os.Getwd()
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error: failed to get current directory: %v\n", err)
		os.Exit(1)
	}
	return dir
}

