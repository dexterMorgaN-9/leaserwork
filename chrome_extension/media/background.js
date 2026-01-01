chrome.action.onClicked.addListener(() => {
  chrome.tabs.create({
    url: "https://winter0619.itch.io/memory-game"
  });
});