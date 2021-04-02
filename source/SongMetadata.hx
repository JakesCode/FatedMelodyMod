package;

class SongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";
	public var songAuthor:String = "";

	public function new(song:String, week:Int, songCharacter:String, songAuthor:String = "")
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
		this.songAuthor = songAuthor;
	}
}
