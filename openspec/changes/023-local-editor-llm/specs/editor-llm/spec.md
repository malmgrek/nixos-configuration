# Spec Delta

## Purpose

States where the editors' AI features may send buffer contents, when they send
anything at all, and where the credential they present comes from, so that
editing a file never puts its contents on a service off this machine.

## ADDED Requirements

### Requirement: Editor AI reaches only the local server

Every AI feature in Doom Emacs and Neovim -- inline completion and chat -- SHALL
send requests only to the one server the configuration declares, on the
loopback interface. No editor AI feature SHALL have a remote service as a
backend or fallback.

The boundary stops at that server: what it does with a request is decided where
it runs, outside this configuration. That is accepted because the server is
operated outside this repository, and the editors cannot see past its address.

#### Scenario: The server is down

- **WHEN** the local server is not running and the operator requests a
  completion or sends a chat message
- **THEN** the request fails, and nothing is sent to any other host

#### Scenario: No cloud backend is selectable

- **WHEN** the operator lists the backends or adapters a chat feature offers
- **THEN** the local server is the only one

### Requirement: The server is declared once

The server's address and model name SHALL each be declared in exactly one place
in this configuration, and every editor SHALL read them from there. Changing
either SHALL need one edit and no change to any editor configuration.

#### Scenario: The model changes

- **WHEN** the operator changes the declared model name and logs in again
- **THEN** completion and chat in both editors use the new model, and no editor
  configuration was edited

### Requirement: Completion is off until turned on

Inline completion SHALL be off whenever an editor starts, and SHALL send no
request while it is off. One operator action SHALL turn on automatic suggestions
for the rest of that editor session.

#### Scenario: A fresh session sends nothing

- **WHEN** an editor starts and the operator types in any buffer without
  turning completion on
- **THEN** no completion request is made

#### Scenario: Turned on once for the session

- **WHEN** the operator turns completion on and then opens and edits other
  buffers
- **THEN** suggestions appear automatically in each of them until the session
  ends or the operator turns completion off

### Requirement: Chat sends only what the operator gives it

A chat feature SHALL send only the content the operator explicitly includes in
a request. It SHALL offer the model no tools, so the model cannot read files,
buffers or command output on its own.

#### Scenario: The model asks for a file

- **WHEN** a model's reply asks to read a file
- **THEN** the file is not read, because no tool exists to read it

### Requirement: The credential never enters the repository or the store

The server's API key SHALL be read at runtime from a file outside both this
repository and the Nix store. The configuration SHALL name only that file's
path, never the key.

#### Scenario: Searching the configuration for the key

- **WHEN** the system is built and its closure and this repository are searched
  for the key's value
- **THEN** it is found in neither

#### Scenario: The key file is missing

- **WHEN** the key file does not exist and the operator requests a completion or
  sends a chat message
- **THEN** the request fails visibly, and the editor stays usable
