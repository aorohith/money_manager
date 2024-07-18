class CustomUser {
  static bool isCustomUser = false;
  static final List<String> phoneNumbers = [
    // "919191919191",//Global college numbers
    // "917171717171",
    "910000000001",
    "910000000002",
    // "910000000003",
    "910000000004",
    "910000000005",
    "918181818181",
    "916161616161",
    "915151515151",
    "914141414141",
    "913131313131",
    "910000000006",
    "910000000007",
    "910000000008",
    "910000000009",
    "910000000010",
    "910000000011",
    "910000000012",
    "910000000013",
    "910000000014",
    "910000000015",
    "910000000016",
    "910000000017",
    "910000000018",
    "910000000019",
    "910000000020",
    "910000000021",
    "910000000022",
    "910000000023",
    "910000000024",
    "910000000025",
  ];
  static int dataLength = 10;

  static void checkPhoneNumber(String phoneNumber) {
    isCustomUser = phoneNumbers.contains(phoneNumber);
    if (isCustomUser) {
      dataLength = 30;
    }
  }
}
