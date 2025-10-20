{
  programs.freetube = {
    enable = true;

    settings = {

      # General
      backendFallback = true;
      checkForUpdates = false;
      checkForBlogPosts = false;
      backendPreference = "local";

      # Player
      proxyVideos = true;
      useSponsorBlock = true;
      autoplayVideos = false;
      defaultQuality = "2160";
      autoplayPlaylists = false;
      allowDashAv1Formats = true;

      # Distraction Free
      hidePlaylists = true;
      expandSideBar = false;
      hidePopularVideos = true;
      hideTrendingVideos = true;

      # Privacy
      rememberSearchHistory = false;
      enableSearchSuggestions = false;

      # Theme
      barColor = false;
      hideLabelsSideBar = true;
      baseTheme = "catppuccinMocha";
      secColor = "CatppuccinMochaMauve";
      mainColor = "CatppuccinMochaMauve";
    };
  };
}
