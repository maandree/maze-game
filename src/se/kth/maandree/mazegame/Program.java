package se.kth.maandree.mazegame;

import java.io.*;
import java.util.*;


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
	
	
	// 27 79 65 ↑  27 27 79 65 M-↑  27 91 49 59 5{0,1,2,3,4,5,6} 65 *-↑
	// 27 79 66 ↓  27 27 79 66 M-↓  27 91 49 59 5{0,1,2,3,4,5,6} 66 *-↓
	// 27 79 67 →  27 27 79 67 M-←  27 91 49 59 5{0,1,2,3,4,5,6} 67 *-→
	// 27 79 68 ←  27 27 79 68 M-→  27 91 49 59 5{0,1,2,3,4,5,6} 68 *-←
	
	final long REG_MASK = 0xFFFFFFL, META_MASK = 0xFFFFFFFFL, ANY_MASK = 0xFFFFFFF0FFFFL;
	
	final long    UP = 0x1B4F41L,    UP_META = 0x1B1B4F41L,    UP_ANY = 0x1B5B313B3041L;
	final long  DOWN = 0x1B4F42L,  DOWN_META = 0x1B1B4F42L,  DOWN_ANY = 0x1B5B313B3042L;
	final long RIGHT = 0x1B4F43L, RIGHT_META = 0x1B1B4F43L, RIGHT_ANY = 0x1B5B313B3043L;
	final long  LEFT = 0x1B4F44L,  LEFT_META = 0x1B1B4F44L,  LEFT_ANY = 0x1B5B313B3044L;
	
	long start = System.currentTimeMillis();
	
	boolean first = true;
	long buf = 0;
	for (int d;;)
	{
	    if (first)
	    {   d = 'L' - '@';
		first = false;
	    }
	    else if ((d = System.in.read()) == -1)
		break;
	    if ((d == 4) || (d == 'Q') || (d == 'q'))
		break;
	    buf = (buf << 8) | d;
	    long any = buf & ANY_MASK;
	    long meta = buf & META_MASK;
	    long reg = buf & REG_MASK;
	    boolean ctrl = ((buf >> 16) & 255) == 53;
	    
	    int dx = 0, dy = 0;
	    
	    if (d == 'L' - '@')
	    {  // reprint
	    }
	    else if ((any ==    UP_ANY) || (meta ==    UP_META))  dy = ctrl ? -3 : -2;
	    else if ((any ==  DOWN_ANY) || (meta ==  DOWN_META))  dy = ctrl ? 3 : 2;
	    else if ((any == RIGHT_ANY) || (meta == RIGHT_META))  dx = ctrl ? 3 : 2;
	    else if ((any ==  LEFT_ANY) || (meta ==  LEFT_META))  dx = ctrl ? -3 : 2;
	    else if (reg ==    UP)  dy = -1;
	    else if (reg ==  DOWN)  dy = 1;
	    else if (reg == RIGHT)  dx = 1;
	    else if (reg ==  LEFT)  dy = -1;
	    else
		continue;
	    
	    // FIXME
	    
	    long time = (System.currentTimeMillis() - start) / 1000;
	    
	    StringBuilder out = new StringBuilder();
	    out.append("\033[1;1H\033[2KTime: " + time + " s\n\n");
	    
	    // FIXME
	    
	    System.out.print(out.toString());
	    System.out.flush();
	}
	
	System.out.println((System.currentTimeMillis() - start) / 1000 + "." ((System.currentTimeMillis() - start) % 1000));
    }
    
    
    /**
     * Generates a maze
     * 
     * @param  matrix  The matrix to fill
     * @param  height  The height of the matrix
     * @param  width   The width of the matrix
     */
    private static void generate(final boolean[][] matrix, final int height, final int width)
    {
    }

}

