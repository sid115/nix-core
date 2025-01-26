#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Function to print the help page
void print_help() {
  printf("Usage:\n");
  printf("  update_display_name [-t ACCESS_TOKEN] [-r REMOTE] [-u USER] [-d "
         "DISPLAY_NAME] [-h]\n\n");
  printf("Options:\n");
  printf("  -h                Show this help message and exit.\n");
  printf("  -t ACCESS_TOKEN   Your access token for authentication.\n");
  printf("  -r REMOTE         The remote server address.\n");
  printf("  -u USER           The user identifier to update.\n");
  printf("  -d DISPLAY_NAME   The new display name to set.\n\n");
  printf("Example:\n");
  printf("  update_display_name -t my_access_token -r my_remote_server -u "
         "user123 -d \"My New Display Name\"\n");
}

int main(int argc, char *argv[]) {
  char *access_token = NULL;
  char *remote = NULL;
  char *user = NULL;
  char *display_name = NULL;

  for (int i = 1; i < argc; i++) {
    if (argv[i][0] == '-' &&
        strlen(argv[i]) == 2) { // Ensure it is a single-character flag
      switch (argv[i][1]) {
      case 'h':
        print_help();
        return 0;
      case 't':
        if (i + 1 < argc) {
          access_token = argv[++i];
        } else {
          printf("Error: Missing value for -t (ACCESS_TOKEN).\n\n");
          print_help();
          return 1;
        }
        break;
      case 'r':
        if (i + 1 < argc) {
          remote = argv[++i];
        } else {
          printf("Error: Missing value for -r (REMOTE).\n\n");
          print_help();
          return 1;
        }
        break;
      case 'u':
        if (i + 1 < argc) {
          user = argv[++i];
        } else {
          printf("Error: Missing value for -u (USER).\n\n");
          print_help();
          return 1;
        }
        break;
      case 'd':
        if (i + 1 < argc) {
          display_name = argv[++i];
        } else {
          printf("Error: Missing value for -d (DISPLAY_NAME).\n\n");
          print_help();
          return 1;
        }
        break;
      default:
        printf("Error: Unknown option -%c.\n\n", argv[i][1]);
        print_help();
        return 1;
      }
    } else {
      printf("Error: Invalid argument format: %s\n\n", argv[i]);
      print_help();
      return 1;
    }
  }

  if (!access_token || !remote || !user || !display_name) {
    printf("Error: Missing required arguments.\n\n");
    print_help();
    return 1;
  }

  char command[1024];
  snprintf(command, sizeof(command),
           "curl --header \"Authorization: Bearer %s\" "
           "--location --request PUT "
           "'https://%s/_matrix/client/v3/profile/%s/displayname' "
           "--data '{ \"displayname\": \"%s\" }'",
           access_token, remote, user, display_name);

  int result = system(command);

  if (result != 0) {
    printf("\nError: Failed to execute the curl command.\n");
    return 1;
  }

  printf("\nDisplay name updated successfully.\n");
  return 0;
}
