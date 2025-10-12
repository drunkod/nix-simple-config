{ pkgs, lib, ... }: {
  services.espanso = {
    enable = true;
        configs = {
          default = {
        search_shortcut = "ALT+SPACE";
        
        # Backend is correct for X11
        backend = "Clipboard";
        
        # FIX: Remove or comment out toggle_key - the format was wrong
        # toggle_key = "OFF";  # Set to OFF to disable, or use correct format
        
        # Optional: Useful settings
        paste_shortcut = "CTRL+V";
        preserve_clipboard = true;
        show_notifications = true;  # Disable since notifications don't work
        
        # Performance tuning
        pre_paste_delay = 100;
        clipboard_threshold = 100;
    matches = {
		base = {
          matches = [
            {
              trigger = ":mydate";
              replace = "{{mydate}}";
              vars = [
                {
                  name = "mydate";
                  type = "date";
                  params = {
                    format = "%d.%m.%Y";
                  };
                }
              ];
            }

            {
              trigger = ":rand";
              replace = "{{rand}}";
              vars = [
                {
                  name = "rand";
                  type = "random";
                  params.choices = [
		            "Hey there!"
		            "Hello, how are you?"
		            "Hi, nice to see you!"
		            "Greetings!"
		            "Hey, what's up?"
		            "Hello there!"
		            "Hi friend!"
		          ];
                }
              ];
            }
          ];
        };

        greethings = {
          global_vars = [
            {
              name = "clipb";
              type = "clipboard";
			}
            {
              name = "quote";
              type = "shell";
              params = {
                #                cmd = "curl -s 'https://zenquotes.io/api/random' | jq -r '.[0].q'";
                #                cmd = "nix-shell -p neo-cowsay --run \"curl -s 'https://zenquotes.io/api/random' | jq -r '.[0].q' | cowthink\"";
                cmd = "${lib.getExe pkgs.curl} -s https://zenquotes.io/api/random | ${lib.getExe pkgs.jq} -r '.[0].q' | ${pkgs.neo-cowsay}/bin/cowthink";
              };
            }
          ];
          matches = [
            {
              trigger = ":sg";
              replace = "Sehr geehrter ";
            }
            {
              triggers = [
                ":omor"
                ":gmo"
              ];
              replace = "Good morning from the office! 🌄🏢\n\n```\n{{quote}}\n```";
            }
            {
              triggers = [
                ":.omor"
                ":.gmo"
              ];
              replace = "Good morning from the office! 🌄🏢";
            }
            {
              triggers = [ ":gmho" ];
              replace = "Good morning from home office! 🌄🏡\n\n```\n{{quote}}\n```";
            }
            {
              triggers = [ ":.gmho" ];
              replace = "Good morning from home office! 🌄🏡";
            }
            {
              triggers = [
                ":gna"
                ":gnsg"
              ];
              replace = "Gute Nacht und schlaf gut! 🎑🌜🤗🌛🌃";
            }
            {
              triggers = [ ":gmg" ];
              replace = "Guten Morgen, wie hast du geschlafen? 🌄🤗☀️";
            }
            {
              triggers = [ ":vd" ];
              replace = "Vielen Dank!👍️";
            }
            {
              triggers = [ ":ty" ];
              replace = "Thank you! 👍️";
            }
            {
              triggers = [ "эж" ];
              replace = "{{clipb}}";
            }
          ];
        };
	};
  };
}
}
}