package se.kth.maandree.mazegame;


/**
 * This is the main class of the program
 * 
 * @author  Mattias Andrée, <a href="mailto:maandree@kth.se">maandree@kth.se</a>
 */
public class Program
{
    /**
     * Non-constructor
     */
    private Program()
    {
	assert false : "You are not meant to initialise this class [Program],";
    }
    
    
    
    /**
     * This is the main entry point of the porgram
     * 
     * @param  args  Command line arguments
     * 
     * @throws  Exception  On error
     */
    public static void main(final String... args) throws Exception
    {
	int width = 40;
	int height = 40;
        String save = null;
	String load = null;
	String linger = null;
	
	for (final String arg : args)
	    if (linger == null)
		linger = arg;
	    else if (linger.equals("--width"))   width  = Integer.parseInt(arg);
	    else if (linger.equals("--height"))  height = Integer.parseInt(arg);
	    else if (linger.equals("--save"))    save = arg;
	    else if (linger.equals("--load"))    load = arg;
	
	boolean[][] matrix = new boolean[height][width];
	
	if (load != null)
	    try (final InputStream is = new BufferedInputStream(new FileInputStream(load))
		;final Scanner sc = new Scanner(is))
	    {
		height = Integer.parseInt(sc.nextLine());
		width  = Integer.parseInt(sc.nextLine());
		matrix = new boolean[height][width];
		
		for (int y = 0; y < height; y++)
		{   final char[] line = sc.nextLine().toCharArray();
		    final boolean[] row = matrix[y];
		    for (int x = 0; x < width; x++)
			row[x] = line[x] != '#';
		}
	    }
	else
	    generate(matrix, height, width);
	
	final String WALL   = "\033[40m  \033[49m";
	final String FLOOR  = "\033[47m  \033[49m";
        String       PLAYER = "\033[47;30m@@\033[49;39m";
	
	String $COLORTERM = System.getenv("COLORTERM");
	if (($COLORTERM != null) && ($COLORTERM.isEmpty() == false))
	    PLAYER = PLAYER.replace("@@", "😉 ");
	
	if (save != null)
	    try (final OutputStream os = new BufferedOutputStream(new FileOutputStream(save)))
	    {
		os.write((Integer.toString(height) + '\n').getBytes("UTF-8"));
		os.write((Integer.toString(width)  + '\n').getBytes("UTF-8"));
		for (int y = 0; y < height; y++)
		{   final boolean[] row = matrix[y];
		    for (int x = 0; x < width; x++)
			os.write(row[x] ? '.' : '#');
		    os.write('\n');
		}
		os.flush();
	    }
	
	int y = 0, x = 0;
	for (int i = 0; i < height; i++)
	    if (matrix[i][0])
	    {   y = i;
		break;
	    }
    }
    
    
    /**
     * Generates a maze
     * 
     * @param  matrix  The matrix to fill
     * @param  height  The height of the matrix
     * @param  width   The width of the matrix
     */
    private static void generate(final boolean[] matrix, final int height, final int width)
    {
    }

}

