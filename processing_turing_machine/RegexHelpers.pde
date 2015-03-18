/*
    Fionan Haralddottir
    Turing Machine in Processing
    March 2015
*/

ArrayList<String> allRegexMatches(String regex, String content) {
    String[][] matches = matchAll(content,regex);
    ArrayList<String> arrlist = new ArrayList<String>();
    if (matches != null) for (int i = 0; i < matches.length; i++) if (matches[i].length > 0 && matches[i][0] != null && matches[i][0].length() != 0) arrlist.add(matches[i][0]);
    return arrlist;
}

String firstMatch(String regex, String content) {
    ArrayList<String> matches = allRegexMatches(regex, content);
    if (matches.size() > 0) return matches.get(0);
    else return "";
}
