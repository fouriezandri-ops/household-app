/// This app has exactly one household and exactly two members, and there's
/// no auth to derive IDs from (decision #2 in CLAUDE.md — PIN only, no
/// Firebase Auth). So the household and member IDs are fixed constants
/// rather than generated: every install of the app resolves to the same
/// `/households/default` document and the same two `/users/{uid}` docs,
/// with no pairing/invite step needed for both partners' phones to sync.
///
/// [HouseholdRepository.ensureSeeded] creates these documents (with the
/// placeholder names/colors below) the first time either device sees an
/// empty database; renaming a member is a Settings feature for a later
/// milestone.
const defaultHouseholdId = 'default';

const member1Uid = 'member-1';
const member2Uid = 'member-2';

const defaultMemberSeeds = [
  (uid: member1Uid, displayName: 'Partner 1', colorTag: '#3A6351'),
  (uid: member2Uid, displayName: 'Partner 2', colorTag: '#8E5B3C'),
];
