import 'package:flutter/foundation.dart';
import 'package:notes_app_flutter/services/api_client.dart';
import 'package:notes_app_flutter/services/note_service.dart';
import 'package:notes_app_flutter/models/note.dart';

class NotesProvider extends ChangeNotifier {
  
  // states:
  List<Note> _notes = [];
  bool isLoading = false;
  String _errorMessage = '';

  //other date members:
  late final NoteService _noteService;
  final ApiClient _client;

  NotesProvider(this._client) {
    _noteService = NoteService(apiClient: _client, authToken: null);
  }

  // Getters for the private members:
  List<Note> get notes => _notes;  // to fetch all notes 
  String get errorMessage => _errorMessage; // to fetch error message for displying on the UI of the app!!

  // Methods:

  // to fetch all notes:
  Future<void> fetchAllNotes(String? authToken) async {
    isLoading = true;
    _errorMessage = '';
    notifyListeners();
    _noteService.authToken = authToken;
    try {
      _notes = await _noteService.fetchAllNotes();
    } catch (e) {
      if (e is ApiException) {
        _errorMessage = e.message;
      } else {
        _errorMessage = e.toString();
      }
    }
    isLoading = false;
    notifyListeners();
  }

  Future<List<Note>> searchTitle(String title, String authToken)async{
    isLoading = true;
    _errorMessage = '';
    notifyListeners();
    _noteService.authToken = authToken;
    List<Note> searchResults = [];
    try{
      searchResults = await _noteService.searchNotes(title: title, createdAt: null);
    }catch(e){
      if(e is ApiException){
        _errorMessage = e.message;
      }else{
        _errorMessage = e.toString();
      }
    }
    isLoading = false;
    notifyListeners();
    return searchResults;
  }  

  // search using date:
  Future<List<Note>> searchDate(DateTime date, String authToken)async{
    isLoading = true;
    _errorMessage = '';
    notifyListeners();
    _noteService.authToken = authToken;
    List<Note> searchResults = [];
    try{
      searchResults = await _noteService.searchNotes(title: null, createdAt: date);
    }catch(e){
      if(e is ApiException){
        _errorMessage = e.message;
      }else{
        _errorMessage = e.toString();
      }
    }
    isLoading = false;
    notifyListeners();
    return searchResults;
  }

  // fetch note by id:
  Future<Note?> fetchNoteById(int id, String authToken) async {
    isLoading = true;
    _errorMessage = '';
    notifyListeners();
    _noteService.authToken = authToken;
    Note? note;
    try {
      note = await _noteService.fetchNoteById(id);
    } catch (e) {
      if (e is ApiException) {
        _errorMessage = e.message;
      } else {
        _errorMessage = e.toString();
      }
    }
    isLoading = false;
    notifyListeners();
    return note;
  }
}
