import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/notes_service.dart';

class NotesScreen extends StatefulWidget {
  final NotesService notesService;

  const NotesScreen({super.key, required this.notesService});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  late final TextEditingController _noteController;
  late final TextEditingController _titleController;
  late final TextEditingController _searchController;
  late final TextEditingController _pinController;
  late final TextEditingController _newPinController;

  DateTime _selectedDate = DateTime.now();
  String _selectedNoteId = '';
  List<Note> _allNotes = [];
  String _query = '';

  // selection mode
  bool _selectionMode = false;
  final Set<String> _selectedIds = {};

  // preview cache to avoid decrypting in list build
  final Map<String, _Preview> _preview = {};

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController();
    _titleController = TextEditingController();
    _searchController = TextEditingController();
    _pinController = TextEditingController();
    _newPinController = TextEditingController();
    _boot();
  }

  Future<void> _boot() async {
    try {
      await widget.notesService.initialize();
      _refresh();
      _loadFirstForDay(_selectedDate);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    _titleController.dispose();
    _searchController.dispose();
    _pinController.dispose();
    _newPinController.dispose();
    super.dispose();
  }

  bool get _isSplit => MediaQuery.of(context).size.width >= 900;

  DateTime _dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  Note? _currentNote() => widget.notesService.getNoteById(_selectedNoteId);

  void _refresh() {
    final notes = widget.notesService.getAllNotes();
    _allNotes = notes;

    _preview.clear();
    for (final n in notes) {
      final text =
          n.isEncrypted ? widget.notesService.decryptNoteContent(n) : n.content;
      final clean =
          text.replaceAll('\n', ' ').trim().replaceAll(RegExp(r'\s+'), ' ');

      _preview[n.id] = _Preview(
        title: n.title.trim(),
        preview: clean,
        dateText: DateFormat('yyyy-MM-dd').format(n.date),
        chipDay: DateFormat('EEE, MMM d').format(n.date),
      );
    }

    if (mounted) setState(() {});
  }

  List<Note> get _filtered {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return _allNotes;

    return _allNotes.where((n) {
      final p = _preview[n.id];
      final t = (p?.title ?? n.title).toLowerCase();
      final d = (p?.dateText ?? DateFormat('yyyy-MM-dd').format(n.date))
          .toLowerCase();
      final pr = (p?.preview ?? '').toLowerCase();
      return t.contains(q) || d.contains(q) || pr.contains(q);
    }).toList();
  }

  void _loadFirstForDay(DateTime date) {
    final list = widget.notesService.getNotesByDate(date);
    if (list.isEmpty) {
      _selectedNoteId = '';
      _noteController.clear();
      _titleController.clear();
      if (mounted) setState(() {});
      return;
    }

    final n = list.first;
    _selectedNoteId = n.id;
    _selectedDate = _dayOnly(n.date);

    final text =
        n.isEncrypted ? widget.notesService.decryptNoteContent(n) : n.content;
    _noteController.text = text;
    _titleController.text = n.title;

    if (mounted) setState(() {});
  }

  Future<bool> _openNote(Note n) async {
    if (n.isEncrypted) {
      final ok = await _verifyPinDialog();
      if (!ok) return false; // User cancelled PIN dialog
    }

    _selectedNoteId = n.id;
    _selectedDate = _dayOnly(n.date);

    final text =
        n.isEncrypted ? widget.notesService.decryptNoteContent(n) : n.content;
    _noteController.text = text;
    _titleController.text = n.title;

    if (mounted) setState(() {});
    return true; // Successfully opened
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;

    _selectedDate = _dayOnly(picked);
    _loadFirstForDay(_selectedDate);
  }

  Future<void> _newNote() async {
    setState(() {
      _selectedDate = _dayOnly(DateTime.now());
      _selectedNoteId = '';
      _noteController.clear();
      _titleController.clear();
    });

    if (!_isSplit && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => _EditorPage(
            title: 'New note',
            date: _selectedDate,
            noteController: _noteController,
            titleController: _titleController,
            encrypted: false,
            onSave: _save,
            onDelete: _deleteCurrent,
          ),
        ),
      );
    }
  }

  Future<void> _save() async {
    final content = _noteController.text.trim();
    final title = _titleController.text.trim();

    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Write something before saving.')),
      );
      return;
    }

    final current = _currentNote();
    final keepEncrypted = current?.isEncrypted ?? false;

    // Save to selected date and keep encryption state
    await widget.notesService.saveNoteWithEncryption(
      _selectedDate,
      content,
      keepEncrypted,
      title: title,
      noteId: _selectedNoteId.isNotEmpty ? _selectedNoteId : null,
    );

    // After saving: refresh + keep selection stable
    _refresh();

    // if it was a new note, it now has an id stored; we need to re-select it
    // Strategy: reload first note for that day and pick the newest (id desc)
    _loadFirstForDay(_selectedDate);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Saved'), duration: Duration(milliseconds: 900)),
    );
  }

  Future<void> _deleteCurrent() async {
    final note = _currentNote();
    if (note == null) return;

    final ok = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Delete note?'),
            content: const Text('This action cannot be undone.'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel')),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;

    if (!ok) return;

    await widget.notesService.deleteNote(note.id);
    _refresh();
    _loadFirstForDay(_selectedDate);

    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Deleted')));
  }

  // -------- Selection mode actions --------
  void _enterSelection(String id) {
    setState(() {
      _selectionMode = true;
      _selectedIds.add(id);
    });
  }

  void _toggleSelected(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
        if (_selectedIds.isEmpty) _selectionMode = false;
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _exitSelection() {
    setState(() {
      _selectionMode = false;
      _selectedIds.clear();
    });
  }

  Future<void> _bulkDelete() async {
    final count = _selectedIds.length;
    if (count == 0) return;

    final ok = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Delete selected notes?'),
            content: Text(
                'Delete $count note${count > 1 ? 's' : ''}? This action cannot be undone.'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel')),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;

    if (!ok) return;

    for (final id in _selectedIds) {
      await widget.notesService.deleteNote(id);
    }

    _exitSelection();
    _refresh();
    _loadFirstForDay(_selectedDate);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Deleted $count note${count > 1 ? 's' : ''}')),
    );
  }

  Future<void> _bulkLock(bool lock) async {
    final ids = _selectedIds.toList();
    if (ids.isEmpty) return;

    if (!widget.notesService.isPinSet()) {
      _showSetPinDialog();
      return;
    }

    final ok = await _verifyPinDialog();
    if (!ok) return;

    for (final id in ids) {
      final n = widget.notesService.getNoteById(id);
      if (n == null) continue;

      if (lock && n.isEncrypted) continue;
      if (!lock && !n.isEncrypted) continue;

      final plain =
          n.isEncrypted ? widget.notesService.decryptNoteContent(n) : n.content;

      await widget.notesService.saveNoteWithEncryption(
        n.date,
        plain,
        lock,
        title: n.title,
        noteId: n.id,
      );
    }

    _exitSelection();
    _refresh();

    // keep current open note correct
    if (_selectedNoteId.isNotEmpty) {
      final cur = widget.notesService.getNoteById(_selectedNoteId);
      if (cur != null) {
        await _openNote(cur);
      } else {
        _loadFirstForDay(_selectedDate);
      }
    } else {
      _loadFirstForDay(_selectedDate);
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content:
              Text(lock ? 'Locked selected notes' : 'Unlocked selected notes')),
    );
  }

  // -------- PIN dialogs --------
  Future<bool> _verifyPinDialog() async {
    _pinController.clear();
    final result = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            title: const Text('Enter PIN'),
            content: TextField(
              controller: _pinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'PIN',
                prefixIcon: Icon(Icons.lock),
                border: OutlineInputBorder(),
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel')),
              FilledButton(
                onPressed: () {
                  final ok = widget.notesService.verifyPin(_pinController.text);
                  if (!ok) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Incorrect PIN')),
                    );
                    return;
                  }
                  Navigator.pop(context, true);
                },
                child: const Text('Confirm'),
              ),
            ],
          ),
        ) ??
        false;
    return result;
  }

  void _showSetPinDialog() {
    _pinController.clear();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Set PIN'),
        content: TextField(
          controller: _pinController,
          obscureText: true,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'PIN (4+ digits)',
            prefixIcon: Icon(Icons.lock),
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              if (_pinController.text.length < 4) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('PIN must be 4+ digits')),
                );
                return;
              }
              await widget.notesService.setPin(_pinController.text);
              if (!mounted) return;
              Navigator.pop(context);
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('PIN set')));
            },
            child: const Text('Set'),
          ),
        ],
      ),
    );
  }

  void _showChangePinDialog() {
    _pinController.clear();
    _newPinController.clear();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Change PIN'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _pinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Current PIN',
                prefixIcon: Icon(Icons.lock),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _newPinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'New PIN (4+ digits)',
                prefixIcon: Icon(Icons.vpn_key),
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              final ok = widget.notesService.verifyPin(_pinController.text);
              if (!ok) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Incorrect current PIN')),
                );
                return;
              }
              if (_newPinController.text.length < 4) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('New PIN must be 4+ digits')),
                );
                return;
              }
              await widget.notesService.setPin(_newPinController.text);
              if (!mounted) return;
              Navigator.pop(context);
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('PIN updated')));
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleEncryptionForCurrent() async {
    final note = _currentNote();
    if (note == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Save the note first')));
      return;
    }

    if (note.isEncrypted) {
      final ok = await showDialog<bool>(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Unlock note'),
              content: const Text('Remove encryption from this note?'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel')),
                FilledButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Unlock')),
              ],
            ),
          ) ??
          false;

      if (!ok) return;

      final pinOk = await _verifyPinDialog();
      if (!pinOk) return;

      final plain = widget.notesService.decryptNoteContent(note);
      await widget.notesService.saveNoteWithEncryption(
        note.date,
        plain,
        false,
        title: note.title,
        noteId: note.id,
      );

      _refresh();
      await _openNote(widget.notesService.getNoteById(note.id)!);

      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Note unlocked')));
      return;
    }

    // lock
    if (!widget.notesService.isPinSet()) {
      _showSetPinDialog();
      return;
    }

    final pinOk = await _verifyPinDialog();
    if (!pinOk) return;

    final content = _noteController.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Write something first')));
      return;
    }

    await widget.notesService.saveNoteWithEncryption(
      note.date,
      content,
      true,
      title: _titleController.text.trim(),
      noteId: note.id,
    );

    _refresh();
    await _openNote(widget.notesService.getNoteById(note.id)!);

    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Note locked')));
  }

  // -------- UI --------
  PreferredSizeWidget _buildAppBar() {
    if (_selectionMode) {
      final anyEncrypted = _selectedIds.any(
          (id) => widget.notesService.getNoteById(id)?.isEncrypted ?? false);
      final anyUnencrypted = _selectedIds.any(
          (id) => !(widget.notesService.getNoteById(id)?.isEncrypted ?? true));

      return AppBar(
        leading: IconButton(
            onPressed: _exitSelection, icon: const Icon(Icons.close)),
        title: Text('${_selectedIds.length} selected'),
        actions: [
          if (anyUnencrypted)
            IconButton(
              tooltip: 'Lock',
              icon: const Icon(Icons.lock),
              onPressed: () => _bulkLock(true),
            ),
          if (anyEncrypted)
            IconButton(
              tooltip: 'Unlock',
              icon: const Icon(Icons.lock_open),
              onPressed: () => _bulkLock(false),
            ),
          IconButton(
            tooltip: 'Delete',
            icon: const Icon(Icons.delete),
            onPressed: _bulkDelete,
          ),
        ],
      );
    }

    final dateTitle = DateFormat('EEE, MMM d, yyyy').format(_selectedDate);
    final note = _currentNote();
    final encrypted = note?.isEncrypted ?? false;

    return AppBar(
      titleSpacing: 12,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Notes'),
          const SizedBox(height: 2),
          Text(dateTitle, style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
      actions: [
        SizedBox(
          width: _isSplit ? 320 : 220,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: SearchBar(
              controller: _searchController,
              hintText: 'Search',
              leading: const Icon(Icons.search),
              onChanged: (v) => setState(() => _query = v),
              trailing: [
                if (_query.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _query = '');
                    },
                  )
              ],
            ),
          ),
        ),
        IconButton(
          tooltip: 'Pick date',
          icon: const Icon(Icons.calendar_month),
          onPressed: _pickDate,
        ),
        if (encrypted)
          const Padding(
            padding: EdgeInsets.only(right: 6),
            child: Icon(Icons.lock),
          ),
        PopupMenuButton<String>(
          onSelected: (v) {
            switch (v) {
              case 'new':
                _newNote();
                break;
              case 'toggle_lock':
                _toggleEncryptionForCurrent();
                break;
              case 'change_pin':
                _showChangePinDialog();
                break;
              case 'delete':
                _deleteCurrent();
                break;
            }
          },
          itemBuilder: (_) => [
            const PopupMenuItem(
                value: 'new',
                child: ListTile(
                    leading: Icon(Icons.note_add), title: Text('New'))),
            const PopupMenuDivider(),
            const PopupMenuItem(
              value: 'toggle_lock',
              child: ListTile(
                  leading: Icon(Icons.lock), title: Text('Lock / Unlock note')),
            ),
            if (widget.notesService.isPinSet())
              const PopupMenuItem(
                value: 'change_pin',
                child: ListTile(
                    leading: Icon(Icons.vpn_key), title: Text('Change PIN')),
              ),
            const PopupMenuDivider(),
            const PopupMenuItem(
                value: 'delete',
                child: ListTile(
                    leading: Icon(Icons.delete), title: Text('Delete'))),
          ],
        ),
      ],
    );
  }

  Widget _buildList() {
    final notes = _filtered;

    if (notes.isEmpty) {
      return Center(
        child: Text(
          _query.isEmpty ? 'No notes yet' : 'No results',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      itemCount: notes.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final n = notes[i];
        final p = _preview[n.id];
        final isActive = _selectedNoteId == n.id;
        final isChecked = _selectedIds.contains(n.id);

        final title =
            (p?.title.isNotEmpty ?? false) ? p!.title : (p?.chipDay ?? '');
        final preview = p?.preview ?? '';
        final dayNum = DateFormat('d').format(n.date);
        final mon = DateFormat('MMM').format(n.date);

        return KeyedSubtree(
          key: ValueKey(n.id),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onLongPress: () {
              if (!_selectionMode) {
                _enterSelection(n.id);
              } else {
                _toggleSelected(n.id);
              }
            },
            onTap: () async {
              if (_selectionMode) {
                _toggleSelected(n.id);
                return;
              }

              final opened = await _openNote(n);
              if (!opened) return; // User cancelled PIN dialog, stay in list

              if (!_isSplit && mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => _EditorPage(
                      title: 'Edit note',
                      date: n.date,
                      noteController: _noteController,
                      titleController: _titleController,
                      encrypted: n.isEncrypted,
                      onSave: _save,
                      onDelete: _deleteCurrent,
                    ),
                  ),
                );
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isChecked
                    ? Theme.of(context)
                        .colorScheme
                        .primaryContainer
                        .withOpacity(0.75)
                    : (isActive
                        ? Theme.of(context).colorScheme.primaryContainer
                        : Theme.of(context).colorScheme.surface),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  width: isChecked ? 2 : 1,
                  color: isChecked
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context)
                          .colorScheme
                          .outlineVariant
                          .withOpacity(0.7),
                ),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 8,
                    spreadRadius: 0,
                    color: Colors.black.withOpacity(0.05),
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_selectionMode)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Checkbox(
                        value: isChecked,
                        onChanged: (_) => _toggleSelected(n.id),
                      ),
                    ),
                  Container(
                    width: 56,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(dayNum,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.w800)),
                        Text(mon,
                            style: Theme.of(context).textTheme.labelSmall),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                title.isEmpty ? 'Untitled' : title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(fontWeight: FontWeight.w800),
                              ),
                            ),
                            if (n.isEncrypted) const Icon(Icons.lock, size: 16),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          preview.isEmpty ? 'Empty note' : preview,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEditor() {
    final note = _currentNote();
    final encrypted = note?.isEncrypted ?? false;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  DateFormat('EEEE, MMMM d, yyyy').format(_selectedDate),
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w900),
                ),
              ),
              if (_isSplit) ...[
                IconButton(
                  tooltip: 'Lock/Unlock',
                  onPressed: note == null ? null : _toggleEncryptionForCurrent,
                  icon: Icon(encrypted ? Icons.lock_open : Icons.lock),
                ),
                IconButton(
                  tooltip: 'Delete',
                  onPressed: note == null ? null : _deleteCurrent,
                  icon: const Icon(Icons.delete),
                ),
                FilledButton.icon(
                  onPressed: _noteController.text.trim().isEmpty ? null : _save,
                  icon: const Icon(Icons.check),
                  label: const Text('Save'),
                ),
              ],
            ],
          ),
        ),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            controller: _titleController,
            decoration: InputDecoration(
              hintText: 'Title',
              filled: true,
              fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none),
            ),
            maxLines: 1,
            onChanged: (_) => setState(() {}),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                    color: Theme.of(context).colorScheme.outlineVariant),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                child: TextField(
                  controller: _noteController,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  decoration: const InputDecoration(
                    hintText: 'Write here...',
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(fontSize: 16, height: 1.35),
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ),
          ),
        ),
        if (!_isSplit)
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed:
                          _noteController.text.trim().isEmpty ? null : _save,
                      icon: const Icon(Icons.check),
                      label: const Text('Save'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton.filledTonal(
                    onPressed:
                        note == null ? null : _toggleEncryptionForCurrent,
                    icon: Icon(encrypted ? Icons.lock_open : Icons.lock),
                  ),
                  const SizedBox(width: 10),
                  IconButton.filledTonal(
                    onPressed: note == null ? null : _deleteCurrent,
                    icon: const Icon(Icons.delete),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: _buildAppBar(),
      floatingActionButton: _isSplit
          ? null
          : FloatingActionButton.extended(
              onPressed: _newNote,
              icon: const Icon(Icons.note_add),
              label: const Text('New'),
            ),
      body: _isSplit
          ? Row(
              children: [
                SizedBox(width: 420, child: _buildList()),
                const VerticalDivider(width: 1),
                Expanded(child: _buildEditor()),
              ],
            )
          : _buildList(),
    );
  }
}

class _Preview {
  final String title;
  final String preview;
  final String dateText;
  final String chipDay;

  const _Preview({
    required this.title,
    required this.preview,
    required this.dateText,
    required this.chipDay,
  });
}

class _EditorPage extends StatefulWidget {
  final String title;
  final DateTime date;
  final TextEditingController noteController;
  final TextEditingController titleController;
  final bool encrypted;
  final Future<void> Function() onSave;
  final Future<void> Function() onDelete;

  const _EditorPage({
    required this.title,
    required this.date,
    required this.noteController,
    required this.titleController,
    required this.encrypted,
    required this.onSave,
    required this.onDelete,
  });

  @override
  State<_EditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends State<_EditorPage> {
  late final TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _noteController = widget.noteController;
    _noteController.addListener(_onTextChanged);
  }

  void _onTextChanged() => setState(() {});

  @override
  void dispose() {
    _noteController.removeListener(_onTextChanged);
    super.dispose();
  }

  bool get _canSave => widget.noteController.text.trim().isNotEmpty;

  Future<void> _handleSave() async {
    if (!_canSave) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Write something before saving.')),
      );
      return;
    }

    await widget.onSave();

    if (!mounted) return;
    // Close editor after saving (page is only pushed in non-split mode)
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final dateTitle = DateFormat('EEEE, MMMM d, yyyy').format(widget.date);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          if (widget.encrypted)
            const Padding(
                padding: EdgeInsets.only(right: 6), child: Icon(Icons.lock)),
          IconButton(
              tooltip: 'Delete',
              onPressed: () async {
                await widget.onDelete();
                if (!mounted) return;
                Navigator.pop(context);
              },
              icon: const Icon(Icons.delete)),
          IconButton(
              tooltip: 'Save',
              onPressed: _canSave ? _handleSave : null,
              icon: const Icon(Icons.check)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(dateTitle,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w900)),
            const SizedBox(height: 12),
            TextField(
              controller: widget.titleController,
              decoration: InputDecoration(
                hintText: 'Title',
                filled: true,
                fillColor:
                    Theme.of(context).colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none),
              ),
              maxLines: 1,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                      color: Theme.of(context).colorScheme.outlineVariant),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                  child: TextField(
                    controller: widget.noteController,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    decoration: const InputDecoration(
                      hintText: 'Write here...',
                      border: InputBorder.none,
                    ),
                    style: const TextStyle(fontSize: 16, height: 1.35),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SafeArea(
              top: false,
              child: FilledButton.icon(
                onPressed: _canSave ? _handleSave : null,
                icon: const Icon(Icons.check),
                label: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
