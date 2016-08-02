Changes in Console in 0.6.11 (2016-08-02)
===============================================

Improvements:
 * Upgrade MatrixKit version (v0.3.13).
 * Call: Check permissions before accessing to the camera and the microphone.
 * Call Better handle call invites when the app resumes.
 * Call: Improve the sending of local ICE candidates to avoid HTTP 429(Too Many Requests) response
 
Bug fixes:
 * Call: Make audio continue to work when backgrounding the app.
 * Call: Added sanity check on creation of RTCICEServer objects as crashes have been reported.
 * Call: call must be available in 1:1 rooms (invited and banned users do not count).

Changes in Console in 0.6.10 (2016-07-26)
===============================================

Improvements:
 * Upgrade MatrixKit version (v0.3.12).
 * Enable VoIP for 1:1 room
 * Add Markdown support
 
Changes in Console in 0.6.9 (2016-07-04)
===============================================

Improvements:
 * Upgrade MatrixKit version (v0.3.10).

Changes in Console in 0.6.8 (2016-06-01)
===============================================

Improvements:
 * Upgrade MatrixKit version (v0.3.8).
 * Change App badge handling: Replace the missed notifications count with the missed discussions count.

Changes in Console in 0.6.6 (2016-04-26)
===============================================

Improvements:
 * Upgrade MatrixKit version (v0.3.6).

Bug fixes:
 * The application icon badge number is wrong.

Changes in Console in 0.6.5 (2016-04-08)
===============================================

Improvements:
 * Upgrade MatrixKit version (v0.3.5).

Bug fixes:
 * Multiple invitations on Start Chat action.

Changes in Console in 0.6.4 (2016-03-17)
===============================================

Improvements:
 * Upgrade MatrixKit version (v0.3.4).

Changes in Console in 0.6.3 (2016-03-07)
===============================================

Improvements:
 * Upgrade MatrixKit version (v0.3.3).

Bug fixes:
 * SYIOS-202: IOS should no longer reset badge count on launch.

Changes in Console in 0.6.2 (2016-02-09)
===============================================

Improvements:
 * Upgrade MatrixKit version (v0.3.2).

Changes in Console in 0.6.1 (2016-01-29)
===============================================

Improvements:
 * Upgrade MatrixKit version (v0.3.1).

Changes in Console in 0.6.0 (2016-01-22)
===============================================

Improvements:
 * Upgrade MatrixKit version (v0.3.0).
 * AppDelegate: Customize the localized string table.
 * RoomViewController: Display member details in case of long press on avatar.

Bug fixes:
 * lock/unlock whilst viewing photos => no navigation bar.

Changes in Console in 0.5.7 (2015-11-30)
===============================================

Improvements:
 * Upgrade MatrixKit version (v0.2.8).
 * defaults.plist: add pusher app ids definition.

Bug fixes:
 * SettingsViewController: Account details view is not removed on logout.
 * SYIOS-177: Clear MXStore if the app systematically crashes at startup.

Changes in Console in 0.5.6 (2015-11-13)
===============================================

Improvements:
 * Upgrade MatrixKit version (v0.2.7).

Changes in Console in 0.5.5 (2015-11-06)
===============================================

Improvements:
 * Upgrade MatrixKit version (v0.2.5).
 * APNS handling: APNS registration is forced only at the first launch. 
 * Fix screen flickering on logout.
 * AppDelegate: Handle unrecognized certificates by prompting user during authentication challenge.
 * Allow Chrome to be set as the default link handler.
 * SettingsViewController: reload table view only when it is visible.

Bug fixes:
 * HomeViewController: Public room selection is ignored during search session.

Changes in Console in 0.5.4 (2015-10-14)
===============================================

Improvements:
 * Upgrade MatrixKit version (v0.2.4): fix App crash on iOS 9.

Changes in Console in 0.5.3 (2015-09-14)
===============================================

Improvements:
 * Upgrade MatrixKit version (v0.2.3).

Bug fixes:
 * Bug Fix: App crashes on iPad iOS7.

Changes in Console in 0.5.2 (2015-08-13)
===============================================

 * Upgrade MatrixKit version (v0.2.2).

Changes in Console in 0.5.1 (2015-08-10)
===============================================

Improvements:
 * Add localized strings (see MatrixConsole.strings)
 * Error handling: Alert user on MatrixKit error.
 * RecentsViewController: release the current room resources when user selects another room.

Bug fixes:
 * Bug Fix: Settings - The slider related to the maximum cache size is not working.
 * Bug Fix: Settings - The user is logged out when he press "Clear cache" button.

Changes in Console in 0.5.0 (2015-07-10)
===============================================

Improvements:
 * Update Console by applying MatrixKit changes (see Changes in 0.2.0).
 * Support multi-sessions.
 * Multi-session handling: Prompt user to select an account before starting
   chat with someone.
 * Multi-session handling: Recents are interleaved.

Bug fixes:
 * Bug Fix "grey-stuck-can't-click recent bug". The selected room was not
   reset correctly.
 * Room view controller: remove properly members listener.
 * Memory leaks: Dispose properly view controller resources.
 * Bug Fix: RoomViewController - Clicking on the user in the chat room
   displays the user's details but not his avatar.
 * RageShakeManager: Check whether the user can send email before prompting
   him.

Changes in Console in 0.4.0 (2015-04-23)
===============================================

Improvements:
 * Console has its own git repository.
 * Integration of MatrixKit. Most part of the code of Console-pre-0.4.0 has
   been redesigned and moved to MatrixKit.
 * Stability. MatrixKit better seperates model and viewcontroller which fixes
   random multithreading issues Console encountered.
 * Room page: unsent messages are no more lost when the user changes the room
 

Changes in Matrix iOS Console in 0.3.2 and before
=================================================
Console was hosted in the Matrix iOS SDK GitHub repository.
Changes for these versions can be found here:
https://github.com/matrix-org/matrix-ios-sdk/blob/v0.3.2/CHANGES.rst





