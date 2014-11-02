/*
    Regex helper function ported from a project in C++
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
/*
String makeBetweenRegex(final String lhs, final String rhs, boolean inclusive, boolean quotestrings) {
    String wrk_lhs = quotestrings ? Pattern.quote(lhs) : lhs;
    String wrk_rhs = quotestrings ? Pattern.quote(rhs) : rhs;
    String regex = "";
    if (wrk_lhs.equals(wrk_rhs)) {
        //Todo
    }
    else {
        regex += "(";
        if (inclusive) regex += "(" + wrk_lhs + ")";
        regex += "(?<=" + wrk_lhs + ")([\\S\\s])+(?=" + wrk_rhs + ")";
        if (inclusive) regex += "(" + wrk_rhs + ")";
        regex += ")";
    }
    println("built regex as " + regex);
    return regex;
}

String makeBetweenRegex(final String lhs, final String rhs) {
    return makeBetweenRegex(lhs, rhs, true, true);
}
*/
