class ConstString {
  //error message
  static const String timeOut = "timed out";
  static const String timeOut2 = "TimeoutException";
  static const String platformException = "SocketException: Failed host lookup";
  static const String unAuthorizedMessage =
      'To view the contents, kindly contact the admin.';

  static const List<String> allowedFileExtension = [
    'pdf',
    'doc',
    'docx',
  ];
  static const String note = 'NOTE: ';
  static const String noteDesc = 'Kindly fill all the details';
  // 'The more you fill this form the better result you will get.';
  static const String startToBuildYourProfile = "Start to Build your Profile";
  static const String welcomeTo = 'Welcome to ';
  static const String bSmartJob = '\nBSmartJobs';
  static const String welcomeToBsDesc = 'Let’s Start your Journey';
  static const String welcomeToBsDesc2 =
      'To get the best job for yourself help us build your detailed profile';
  static const String buildYourProfile = 'Build Your Profile';
  static const String updateProfile = 'Update Profile';
  static const String saveAndNext = 'Save & Next';
  static const String saveChanges = "Save Changes";
  static const String previous = 'Previous';

  // personal details screen
  static const String genderLabel = 'Gender';
  static const String dOBLabel = 'Date of Birth';
  static const String mobileNumberLabel = 'Mobile Number';
  static const String differentlyAbled = 'Differently Abled';
  static const String nationality = 'Nationality';
  static const String indianWorkPermitTitle = 'Indian Work Permit';
  static const String indianWorkPermit = 'I HAVE INDIAN WORK PERMIT';
  static const String address = 'Address';
  static const String pinCode = 'Pin Code';
  static const String state = 'State';
  static const String locality = 'Locality/Town';
  static const String fullAddress = 'Full Address';
  static const List<String> genderList = [
    'Female',
    'Male',
    'Others'
  ]; // 0 - Female , 1- Male , 2- Others

  static const String selectGenderHintText = 'Select gender';
  static const String selectDOBHintText = 'Select date of birth';
  static const String selectDifferentlyAbledHintText =
      'Select differently abled';
  static const String selectNationality = 'Select nationality';
  static const String pinCodeHintText = 'Enter pin code';
  static const String fullAddressHintText = 'Enter full address';
  static const String stateHintText = 'Enter state';
  static const String selectLocalityHintText = 'Select locality';

  // validate message
  static const String requiredFieldGender = 'Please select gender';
  static const String requiredFieldDOB = 'Please select date of birth';
  static const String requiredFieldMobile = 'Please enter mobile number';
  static const String requiredFieldPinCode = 'Please enter pin code';
  static const String requiredFieldState = 'Please enter state';
  static const String requiredFieldLocality = 'Please enter locality/town';
  static const String requiredFieldFullAddress = 'Please enter full address';
  static const String invalidMobileNumber = 'Please enter valid mobile number';
  static const String invalidPinCode = 'Please enter valid pin code';

  // education screen
  static const String currentInstituteLabel = 'Current Institute';
  static const String instituteLabel = 'Institute';
  static const String programLabel = 'Program';
  static const String specialisationLabel = 'Specialisation';
  static const String programTypeLabel = 'Program Type';
  static const String programDurationLabel = 'Program Duration';
  static const String selectMarks = 'Select Marks';
  static const String previousEducationLabel = 'Previous Education';
  static const String selectMarksLabel = 'Select Marks';
  static const String schoolCollegeLabel = 'School/College Name';
  static const String boardLabel = 'Board';
  static const String cityLabel = 'City';
  static const String passOutLabel = 'Pass out Year';
  static const String addMoreEducation = 'Add More Education';

  // education hints
  static const String currentInstituteHintText = 'Enter current institute';
  static const String chooseInstituteHintText = 'Choose institute';
  static const String programHintText = 'Choose program';
  static const String specialisationHintText = 'Select specialisation';
  static const String programTypeHintText = 'Choose program type';
  static const String startingYearHintText = 'Starting Year';
  static const String endingYearHintText = 'Ending Year';

  // education radio widget strings
  static const String marksLabel = 'Marks in %';
  static const String marksHintText = 'Enter marks %';
  static const String gpaOutOfHintText = 'Select out of';
  static const String enterGPAHintText = 'Enter GPA';

  static const List<String> salaryList = [
    '0 - 3 Lakhs',
    '3 - 6 Lakhs',
    '6 - 10 Lakhs',
    '10 - 15 Lakhs',
    '15 - 25 Lakhs',
    '25 - 50 Lakhs',
    '50 - 75 Lakhs',
    '75 - 100 Lakhs',
    '1 - 5 Cr',
    'Not Disclosed',
  ];

  static const List<String> stipendList = [
    'Unpaid',
    '0 - 5k',
    '5k - 10k',
    '10k - 15k',
    '15k - 20k',
    '20k - 25k',
    '25k - 30k',
    'Above 30k',
  ];

  static const List<String> gpaList = [
    '10',
    '9',
    '8',
    '7',
    '6',
    '5',
    '4',
  ];

// validate message
  static const String requiredCurrentEducation =
      'Please add current education details';
  static const String requiredClassXII = 'Please add class XII details';
  static const String requiredClassX = 'Please add class X details';
  static const String requiredFieldInstitute = 'Please enter current institute';
  static const String requiredInstitute = 'Please select institute';
  static const String requiredFieldProgram = 'Please select program';
  static const String requiredFieldSpecialisation =
      'Please select specialisation';
  static const String requiredFieldProgramType = 'Please select program type';
  static const String requiredFieldProgramDuration =
      'Please select program duration';
  //start year
  static const String requiredFieldStartYear = 'Please select start year';
  //end year
  static const String requiredFieldEndYear = 'Please select end year';
  //end year should be greater than start year
  static const String endYearShouldBeGreater =
      'End year should be greater than start year';
  static const String requiredMarksOrGPA = 'Please enter marks or GPA';
  static const String requiredFieldSchoolCollege =
      'Please enter school/college name';
  static const String requiredFieldBoard = 'Please enter board';
  static const String requiredFieldCity = 'Please enter city';
  static const String requiredFieldPassOut = 'Please enter pass out year';
  static const String requiredFieldMarks = 'Please enter marks';
  static const String requiredFieldEducation = 'Please enter education';
  static const String requiredFieldSpecialization =
      'Please enter specialization';

  // professional details screen
  static const String previousCompanyLabel = 'Previous Company';
  static const String anotherPreviousCompany = 'ADD ANOTHER PREVIOUS COMPANY';
  static const String designationLabel = 'Designation';
  static const String durationInCompanyLabel = 'Duration in this Company';
  static const String jobProfileLabel = 'Job Profile';
  static const String addMoreCompany = 'Add More Company';
  //hint
  static const String previousCompanyHintText = 'Enter previous company';
  static const String designationHintText = 'Enter designation';
  static const String jobProfileHint = 'Enter job profile';
  static const List<String> monthsList = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];

  // professional detail hints
  static const String joiningMonthHintText = 'Joining Month';
  static const String leavingMonthHintText = 'Leaving Month';

  // validate message
  static const String requiredFieldPreviousCompany =
      'Please enter previous company';
  static const String requiredFieldDesignation = 'Please enter designation';
  static const String requiredFieldDurationInCompany =
      'Please enter duration of company';
  //start date
  static const String requiredFieldStartDate = 'Please select start date';
  //end date
  static const String requiredFieldEndDate = 'Please select end date';
  //end date should be greater than start date
  static const String endDateShouldBeGreater =
      'End date should be greater than start date';
  static const String requiredFieldJobProfile = 'Please enter job profile';

  //job preference screen
  static const String preferredLocation = 'Preferred Location';
  static const String preferredFunctionalArea = 'Preferred Functional Area';
  static const String preferredIndustry = 'Preferred Industry';
  static const String preferredSalary = 'Preferred Salary (LPA)';
  static const String preferredJobType = 'Job Type';
  static const String preferredEmploymentType = 'Employment Type';
  static const String preferredShift = 'Preferred Shift';
  static const String locationHint = "Select Location";
  static const String industryHint = "Select industry";
  static const String nationalityHint = "Select nationality";
  static const String functionalHint = "Select functional area";
  static const String jobTypeHint = "Select Job Type";
  static const String jobType = "Job Type";
  static const String jobTypeSubText = " (Select anyone of the options)";
  static const String employmentType = "Employment Type";
  static const String preferredSalaryHint = "Enter preferred salary";
  static const String preferredStipendHint = "Enter preferred stipend";
  static const String employmentTypeHint = "Select employment Type";
  static const String stipendPerMonth = "Stipend per month";
  static const String shiftHint = "Select shift";
  static const String requiredFieldJobRole = "Please select job role";

  static const String agreeTermsAndConditionValidation =
      'Please agree to the terms and conditions to proceed';

  // Job Applies screen
  static const String bSmartJobs = 'BSmart Jobs';
  static const String profile = 'Profile';
  static const String applies = 'Applied';
  static const String home = 'Home';
  static const String jobList = 'Job List';
  static const String searchJobHintText = 'Search for Jobs';

  //validate message
  static const String requiredFieldJobLocation =
      'Please select preferred location';
  static const String minTenLocation = 'You can select maximum 10 locations';
  static const String requiredFieldJobFunctionalArea =
      'Please select functional area.';
  static const String requiredFieldJobIndustry =
      'Please select preferred industry';
  static const String requiredFieldJobType = 'Please select job type';
  static const String requiredFieldJobSalary = 'Please enter preferred salary';
  static const String requiredFunctionalArea =
      'Please select preferred functional area';
  static const String requiredFieldEmploymentType =
      'Please select employment type';
  static const String requiredFieldShift = 'Please select shift';

  static const List<String> jobTypes = [
    'Apply for Full Time',
    'Apply for Internship'
  ];

  static const List<String> employmentTypes = [
    'Full Time',
    'Part Time',
  ];

  static const List<String> shifts = [
    'Doesn\'t Matter',
    'Day',
    'Night',
  ];

  //Language
  static const String canReadWrite = 'Can read and write';
  static const String canRead = 'Can read';
  static const String canWrite = 'Can write';
  static const String cantReadWrite = 'Can\'t read and write';
  static const String resumeNoteText =
      "We strongly recommend you to upload your resume as required by recruiting firms";
  static const String language = 'Language';
  static const String selectLanguage = 'Languages you can speak';
  static const String canWriteAsWell = 'Can Write as well';
  static const String selectLanguageError =
      'Please select any language you know';
  static const String addAnotherLanguage = 'Add another language you can speak';
  static const String languageName = 'Language Name';
  static const String enterOtherLanguage = 'Enter other language here';
  static const String read = 'Read';
  static const String write = 'Write';
  static const String addLanguage = 'Add Language';
  static const String addedLanguages = 'Added languages';

  //Key Skills
  static const String keySkillsMax10 = 'Key Skills (maximum 15 skills)';
  static const String keySkills = 'Key Skills';
  static const String keySkillsHint = 'Add skill here';

  // profile detail screen
  static const String personalDetails = 'Personal Details';
  static const String resume = 'Resume';
  static const String education = 'Education';
  static const String professionalDetail = 'Professional Details';
  static const String yourJobPreference = 'Your Job Preference';
  static const String clickToAddResume = 'Click to add resume';
  static const String allowedResumeFileType =
      'Allowed file types are pdf & doc format to a maximum size of 5 MB';
  static const String keySkillsError = 'You can add up to 15 skills.';
  static const String keySkillsRequired = 'Please select key skills.';
  static const String fullTime = 'Full time';
  static const String internship = 'Internship';
  //bottomsheet agreement
  static const String bottomSheetAgreement = "I agree to the";

  //job Qa
  static const String recruiterQuestion = 'Recruiter\'s Questions';
  static const String skip = "Skip";
  static const String submit = "Submit";
  static const String alert = 'Alert';
  static const String submitNow = "Submit Now";
  static const String cancel = "Cancel";

  //search job
  static const String noJobApplied = 'No job applications yet?';
  static const String noJobDetails =
      'Find your dream job according to your skillset.';
  // 'Let\'s change that and find your perfect fit!';
  static const String getStarted = "Get Started";
  static const String searchJob = "Search Job";
  static const String searchJobs = "Search jobs";
  static const String searchJobsButtonText = "Search Jobs";
  static const String designationHint = "Enter designation";
  static const String designation = "Designation";
  static const String skills = "skills";
  static const String skillsError = 'You can select only 5 skills';
  static const String selectSkills = "select Skills.";
  static const String location = "Location";
  static const String max10DesignationValidation =
      'You can only enter maximum 10 designations';

  //job alerts
  static const String jobAlerts = "Job Alerts";
  static const String filters = 'Filters';
  static const String applyFilters = "Apply Filter";
  static const String clearFilters = "Clear All";

  // job home
  static const String lastSearch = 'Last Search';
  static const String jobsForYou = 'Jobs for you';
  static const String cvDownloaded = 'CV Downloaded';
  static const String profileViewed = 'Profile Viewed';
  static const String contactViewed = 'Contact Viewed';
  static const String bookmarked = 'Bookmarked';
  static const String recruitersActions = 'Recruiters Actions';

  // job filters
  static const String selectAll = 'Select All';

  // job details
  static const String noOfOpenings = 'No. of Openings';
  static const String functionalArea = 'Functional Area';
  static const String workMode = 'Work Mode';
  static const String postedOn = 'Posted On';
  static const String jobDescription = 'Job Description';
  static const String eligibility = 'Eligibility';
  static const String program = 'Program';
  static const String specialisationRequired = 'Specialisation required';
  static const String minGPARequired = 'Min. GPA required';
  static const String minMarksRequired = 'Min. Marks required';
  static const String workExperienceRequired = 'Work Experience required';
  static const String aboutCompany = 'About Company';
  static const String applyNow = 'Apply Now';
  static const String youHaveApplied = 'You have Applied';
  static const String appliedOn = 'Applied On:';
  static const String sendReminderToCompany = 'Send a reminder to Company';
  static const String jobClosed = 'Job Closed';

  // recruiter questions
  static const String recruiterQuestions = 'Recruiter\'s Questions';
  static const String skipForNow = 'Skip for Now';
  static const String saveNow = 'Save Now';
  static const String enterAnswerHereHintText = 'Enter your answer here';

  // job applies
  static const String activitiesOnAppliedJobs =
      'Activities on your applied jobs';
}
