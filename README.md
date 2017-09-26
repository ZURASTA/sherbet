[![Stories in Ready](https://badge.waffle.io/ZURASTA/sherbet.png?label=ready&title=Ready)](https://waffle.io/ZURASTA/sherbet?utm_source=badge) [![CircleCI](https://circleci.com/gh/ZURASTA/sherbet.svg?style=svg)](https://circleci.com/gh/ZURASTA/sherbet)
# Sherbet (Contact Management)

Manages the contacts belonging to different identities. A contact may be any kind of communication method between the service and the identity, where that identity is the owner of that communication method.


### Usage

The service component (`Sherbet.Service`) is an OTP application that should be started prior to making any requests to the service. This component should only be interacted with to configure/control the service explicitly.

An API (`Sherbet.API`) is provided to allow for convenient interaction with the service from external applications.


### Verification/Reclamation

A contact is uniquely associated with an identity. When first associated, the contact will be in an unverified state (cannot confirm whether the identity is the actual owner of the contact). During this state, the contact can remain associated with the identity, and used by the identity (__however care should be taken when deciding on how and what to communicate to a contact in this state__), but it can also be reclaimed by the actual owner (disassociated on request by the owner). While a verified contact (confirmed the identity is the owner of the contact) cannot be reclaimed, the owning identity must remove this contact to disassociate it.

Whilst a contact is unverified, a reclamation (removal) request can be made by an external user. This request will cause a temporary key to be sent to the contact in question, where the owner of the contact can then reclaim it. Once a contact has been reclaimed, it is disassociated from its previous identity. It can then be associated with a new identity.

A contact can be verified by making a verification request, which will cause a key to be sent to the contact. The owner can then follow through and verify the given contact. __Note: verification (submitting the verification key) should be treated as an unsafe process, in order to prevent someone else verifying a contact associated with someone else's identity, the verification prompt (finalisation) should also require the user to prove their identity (they are that identity; e.g. an active login session).__ Once verified no one can make a reclamation request on that contact.


### Priority

An identity can choose a priority (__primary__ or __secondary__) to associate with a contact. Only one contact (of the same type; e.g. email) may be made primary. The primary priority should be used to specify the contact that is the preferred option for that identity/user.


## Safety

Due to the fact that an identity could associate with a contact that they don't own, or the owner of the contact could attempt to verify the contact that is associated with some other identity, care must be taken when interacting with this service and the contacts being managed.

For any functions that require an identity ID, the best practice is to treat those operations as insecure. And so the identity should be correctly authenticated before performing the operation (e.g. an active login session/trusted party). Functions that do not require an identity ID can be treated as secure, however access to them should be kept within reason (determine it on a per function basis; e.g. `request_removal/1` should be accessible to anyone, while `owner/1` should probably be kept private/accessed by only trusted parties).

The next thing is to keep in mind that unverified contacts may not be owned by the identity and therefore care must be taken when communicating with them. Ideally only verification or reclamation requests should be sent to it, while any sensitive information should not.


Contacts
--------

Support for contacts can be added by implementing the behaviours in `Sherbet.Service.Contact.Communication.Method`.


### Email

Support for email based contacts is provided by the `Sherbet.Service.Contact.Communication.Method.Email` implementation.

Email verification/removal requests are delivered using the `Cake` service. The templates for those emails can be customised in the config file, more information on how to customise them can be found in `Sherbet.Service.Contact.Communication.Method.Email.VerificationKey.Template` and `Sherbet.Service.Contact.Communication.Method.Email.RemovalKey.Template`.


### Mobile

Support for mobile based contacts is provided by the `Sherbet.Service.Contact.Communication.Method.Mobile` implementation.

Mobile verification/removal requests are delivered by __todo: sms service__.


Configuration
-------------

The service may be configured with the following options:

### Setup Mode

The service has two setup modes: `:auto` and `:manual`. When the service is started in `:auto`, it will automatically handle creating and migrating the database. When the service is started in `:manual`, the state of the database is left up to the user to manually setup.

By default the service runs in `:auto` mode. To change this behaviour, pass in the `{ :setup_mode, mode }` when starting the application.

### Database

The database options can be configured by providing the config for the key `Sherbet.Service.Repo`.

For details on how to configure an [Ecto repo](https://hexdocs.pm/ecto/Ecto.Repo.html).

__Note:__ If a PostgreSQL database is used, the service will create a custom type. For details on how to interact with this type, see the [EctoEnum docs](http://hexdocs.pm/ecto_enum).
