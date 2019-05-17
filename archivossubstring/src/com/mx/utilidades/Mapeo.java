package com.mx.utilidades;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;

public class Mapeo {
	
	public boolean mapeoDatos(String ruta, ArrayList<String> cadenas) {		
		String startString ="MXS00100727A";
		String contains="SP_";
		char a[]= {' ','('};
		String string="";
		try {
		BufferedReader input = new BufferedReader(new FileReader(ruta));
		String data_a="GRANT EXECUTE ON tmp TO MXS10000883A;";
		String data_b="GRANT SELECT ON tmp TO MXS10000883A;";
		String rep="tmp";		
		while(( string = input.readLine()) != null ) {	
			if(string.contains(startString) ) {
					for (String tmp : getCadena(string,startString,a)) {
						if(!tmp.isEmpty() && tmp.contains(contains)) {	
							insertaCadenas(cadenas, data_a.replace(rep, tmp) );
						}else if(!tmp.isEmpty()) {
							insertaCadenas(cadenas,data_b.replace(rep, tmp));
						}
					}
			}	
		}
		input.close();
		return true;
		}catch(IOException io) {
			io.printStackTrace();
			return false;
		}
		
	}	

	private static ArrayList<String> getCadena(String cadena, String start, char[] end) {	
		ArrayList<String> result = new ArrayList<>();
		int longitud = cadena.length()-1;
		int front=0;
		for(int i = 0; i <= (longitud - (start.length())); i++) {		
			if(cadena.substring(i, i + (start.length()) ).equals(start)) {				
				front = (i + (start.length()));
				while(front > 0) {
					if(cadena.length() == front || cadena.charAt(front) == end[0] || cadena.charAt(front) == end[1]) {
						result.add(cadena.substring(i, front).toUpperCase()) ;
						i=front;
						front = -1;
					}
					front++;
				}
			}
		}		
		return result;
	}
	
	private static void insertaCadenas(ArrayList<String> cadenas, String valores) {
		boolean bandera= false;
		if(cadenas.isEmpty()) {
			cadenas.add(valores);
		}else {
			for (String string : cadenas) {
				if(string.equals(valores))
					bandera =true;
			}
			if(!bandera) {
				cadenas.add(valores);				
			}
		}		
	}
}
