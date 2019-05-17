package com.mx.utilidades;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;

/*
 * Descripcion: Esta aplicacion recibe un archivo txt y extrae subcadenas, para su funcionamiento se indica 
 * con que cadena inicia el string que se desea extraer asi como el caracter con el que termina la cadena.
 * luego la subcadena que se extra se concatena con alguna otra cadena o sentencia en este caso.
 * por ultimo la deposita en un archivo de salida .txt
 */
public class Extraccion {
	
	public static void main(String[] args) {
		ArrayList<String> cadenas = new ArrayList<>();	
		Mapeo map = new Mapeo();
		String projectpath=System.getProperty("user.dir");
		String outfile_nam= projectpath + "\\src\\out.txt";
		String[] rutas= {projectpath +"\\inputest.sql"};
				
		try {			
		for(int a = 0; a < rutas.length; a++) {
			System.out.println("Trabajando con archivo: "+rutas[a]);
			map.mapeoDatos(rutas[a],cadenas);
		}			
		FileWriter out = new FileWriter(new File(outfile_nam));
		for (String string2 : cadenas) {
			out.write(string2 + "\n");
		}		
		System.out.println("ArchivoCreado: "+outfile_nam);
		out.flush();
		out.close();
		}catch(IOException io) {
			io.printStackTrace();
		}
	}
}
