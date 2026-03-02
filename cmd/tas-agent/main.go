package main

import (
	"flag"
	"fmt"
	"os"
	"strings"

	tasagent "github.com/trungtran/tas-agent"
	"github.com/trungtran/tas-agent/internal/installer"
	"github.com/trungtran/tas-agent/internal/profiles"
)

// version is set at build time via -ldflags "-X main.version=..."
var version = "dev"

const usage = `tas-agent — Install AI agent skills, rules, and workflows into your project.

USAGE:
  tas-agent <command> [flags]

COMMANDS:
  install <profile>   Install skills and rules for a profile
  list [profile]      List available profiles and skills
  version             Show version information

INSTALL FLAGS:
  --target, -t <dir>  Target directory (default: current directory)
  --force, -f         Overwrite existing files
  --dry-run           Show what would be installed without making changes

PROFILES:
  be         Backend (NestJS, Java, Go, Python, Rust, C, Dart)
  fe         Frontend (React, Next.js, Vue, Svelte, React Native)
  fullstack  Full-stack (backend + frontend)
  all        Everything

  Individual skills can also be installed by name:
    tas-agent install golang
    tas-agent install nestjs

EXAMPLES:
  tas-agent install be
  tas-agent install fe --target ./my-project
  tas-agent install all --force
  tas-agent list
  tas-agent list be
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
	case "list":
		runList(os.Args[2:])
	case "version", "--version", "-v":
		fmt.Printf("tas-agent version %s\n", version)
	case "help", "--help", "-h":
		fmt.Print(usage)
	default:
		fmt.Fprintf(os.Stderr, "Error: unknown command %q\n\n", cmd)
		fmt.Print(usage)
		os.Exit(1)
	}
}

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

	// Profile is always the first positional argument; parse flags from the rest.
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

	targetDir := *target
	if targetDir == "" {
		var err error
		targetDir, err = os.Getwd()
		if err != nil {
			fmt.Fprintf(os.Stderr, "Error: failed to get current directory: %v\n", err)
			os.Exit(1)
		}
	}

	profile, err := profiles.Get(profileName)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error: %v\n", err)
		os.Exit(1)
	}

	opts := installer.Options{
		DryRun: *dryRun,
		Force:  *force,
	}

	if err := installer.Install(tasagent.AgentFS, profile, targetDir, opts); err != nil {
		fmt.Fprintf(os.Stderr, "Error: %v\n", err)
		os.Exit(1)
	}
}

func runList(args []string) {
	fs := flag.NewFlagSet("list", flag.ExitOnError)
	if err := fs.Parse(args); err != nil {
		os.Exit(1)
	}

	if fs.NArg() > 0 {
		profileName := fs.Arg(0)
		profile, err := profiles.Get(profileName)
		if err != nil {
			fmt.Fprintf(os.Stderr, "Error: %v\n", err)
			os.Exit(1)
		}
		profiles.PrintProfile(profile)
	} else {
		profiles.PrintAll()
	}
}
