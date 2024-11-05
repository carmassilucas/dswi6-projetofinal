<%@page import="exception.PasswordsNotMatches"%>
<%@page import="entity.User"%>
<%@page import="service.UserService"%>
<%@page contentType="text/html;charset=UTF-8" language="java" %>

<%
	var sessionUser = session.getAttribute("user");
	
	if (sessionUser == null || !(sessionUser instanceof User)) {
		response.sendRedirect("sign-in.jsp");
		return;
	}
		
	User user = (User) sessionUser;
	
	if (user.userType() != 2L) {
		response.sendRedirect("rent.jsp");
		return;
	}
	
	if (user.actived()){
		session.setAttribute("erro", "Senha já redefinida");
		response.sendRedirect("rentals.jsp");
		return;
	}

    String erro = "";
    String sucesso = "";

    if (request.getMethod().equalsIgnoreCase("post")) {
        String password1 = request.getParameter("password1");
        String password2 = request.getParameter("password2");
        
        try {
            var updatedUser = UserService.getInstance().updatePassword(password1, password2, user);
            session.setAttribute("user", updatedUser);
            session.setAttribute("sucesso", "Senha atualizada com sucesso.");
    		response.sendRedirect("rentals.jsp");
    		return;
        } catch (PasswordsNotMatches e) {
            erro = e.getMessage();
        }
    }
    
    if (session.getAttribute("sucesso") != null) {
    	sucesso = session.getAttribute("sucesso").toString();
    	session.removeAttribute("sucesso");
    }
    
    if (session.getAttribute("erro") != null) {
    	erro = session.getAttribute("erro").toString();
    	session.removeAttribute("erro");
    }
%>

<!doctype html>
<html lang="pt-br">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Trocar Senha | Natureza Viva</title>
        <script src="https://cdn.tailwindcss.com"></script>
    </head>
    <body class="bg-gray-100 flex flex-col items-center justify-center min-h-screen">
        <header class="fixed top-0 left-0 w-full bg-white shadow mb-6 z-10">
            <div class="max-w-6xl mx-auto px-4 py-4 flex items-center">
                <i class="fas fa-leaf text-green-500 mr-2"></i>
                <h1 class="text-xl font-bold text-green-500">Natureza Viva</h1>
            </div>
        </header>

        <div class="bg-white p-6 rounded-lg shadow-md w-full max-w-md mt-16">
            <h1 class="text-2xl mb-6 text-center">Troque sua Senha</h1>

            <form action="<%= request.getRequestURI() %>" method="post">
                <div class="mb-4">
                    <label for="password1" class="block text-gray-700 mb-2">Nova senha</label>
                    <input type="password" name="password1" class="w-full p-3 border border-gray-300 rounded-lg" placeholder="Digite sua nova senha" required>
                </div>

                <div class="mb-4">
                    <label for="password2" class="block text-gray-700 mb-2">Confirmar senha</label>
                    <input type="password" name="password2" class="w-full p-3 border border-gray-300 rounded-lg" placeholder="Confirme sua nova senha" required>
                </div>

                <button type="submit" class="w-full bg-blue-500 text-white py-3 rounded-lg hover:bg-blue-600 transition-colors">Atualizar</button>
            </form>

            <p class="mt-4 text-gray-600 text-center">Voltar ao <a href="sign-in.jsp" class="text-blue-500 hover:underline">login</a></p>
        </div>

        <% if (!erro.equals("")) { %>
            <div class="fixed bottom-4 right-4 bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded shadow-lg" role="alert">
                <strong class="font-bold">Erro:</strong>
                <span class="block sm:inline"><%= erro %></span>
            </div>
        <% } else if (!sucesso.equals("")) { %>
            <div class="fixed bottom-4 right-4 bg-green-100 border border-green-400 text-green-700 px-4 py-3 rounded shadow-lg" role="alert">
                <strong class="font-bold">Sucesso:</strong>
                <span class="block sm:inline"><%= sucesso %></span>
            </div>
        <% } %>
    </body>
</html>
