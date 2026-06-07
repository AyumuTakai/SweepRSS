sealed class Selection {
  const Selection();
}

class SelectionAll extends Selection {
  const SelectionAll();
}

class SelectionUnread extends Selection {
  const SelectionUnread();
}

class SelectionFlagged extends Selection {
  const SelectionFlagged();
}

class SelectionTrash extends Selection {
  const SelectionTrash();
}

class SelectionFolder extends Selection {
  final String folderId;
  const SelectionFolder(this.folderId);
}

class SelectionFeed extends Selection {
  final String feedId;
  const SelectionFeed(this.feedId);
}
