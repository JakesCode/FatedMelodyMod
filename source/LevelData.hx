package;

class LevelData
{
	public var levelName:String = "";

	public function new(levelName:String)
	{
		this.levelName = levelName;
	}
}

class LevelRootObject
{
    public var levelNames:List<String>;
    public var levels:List<LevelData>;

    public function new(levelNames:List<String>, levels:List<LevelData>)
    {
        this.levelNames = levelNames;
        this.levels = levels;
    }
}