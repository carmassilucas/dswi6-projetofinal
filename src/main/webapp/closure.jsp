<%@page import="exception.RentInvalidException"%>
<%@page import="dto.RentReserved"%>
<%@page import="service.UserRentService"%>
<%@page import="exception.RentNotFoundException"%>
<%@page import="java.util.Map"%>
<%@page import="service.RentService"%>
<%@page import="dto.RentResponse"%>
<%@page import="entity.User"%>
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
    
    if (!user.actived()) {
    	session.setAttribute("erro", "Usuário inativo, altere sua senha para ativar.");
    	response.sendRedirect("change-password.jsp");
    	return;
    }
    
    String erro = "";
	String sucesso = "";
    
    if (request.getMethod().equalsIgnoreCase("post")) {
		String action = request.getParameter("action");
		String userRentId = request.getParameter("id");
	    
	    if (userRentId == null || action == null) {
	    	response.sendRedirect("closure.jsp");
	    	return;
	    }
	    
	    try {
	    	if (action.equals("approve")) {
		    	UserRentService.getInstance().approve(Long.parseLong(userRentId));
		    	sucesso = "Solicitação aprovada com sucesso!";
		    } else if (action.equals("recuse")) {
		    	UserRentService.getInstance().cancel(Long.parseLong(userRentId));
		    	sucesso = "Solicitação recusada com sucesso!";
		    } else if (action.equals("finalize")) {
		    	UserRentService.getInstance().conclude(Long.parseLong(userRentId));
		    	sucesso = "Alguel de espaço concluido com sucesso!";
		    } else if (action.equals("occurrence")) {
		    	UserRentService.getInstance().conclude(Long.parseLong(userRentId));
		    	response.sendRedirect("open-occurrence.jsp?id="+userRentId);
		    	return;
		    }
	    } catch (RentNotFoundException | RentInvalidException e) {
	    	erro = e.getMessage();
	    }
	    
	}
    
    Map<Long, String> rentType = Map.of(1L, "Auditório", 2L, "Salão de festas");
	Map<Long, String> rentStatus = Map.of(1L, "Cancelado", 2L, "Solicitado",  3L, "Alugado", 4L, "Aguardando fechamento", 5L, "Finalizado");
	
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
	    <title>Gerenciar solicitações | Natureza Viva</title>
	    <script src="https://cdn.tailwindcss.com"></script>
	    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
	</head>
	<body class="bg-gray-100 flex flex-col items-center justify-center min-h-screen pt-16">
	    <header class="fixed top-0 left-0 w-full bg-white shadow mb-6 z-10">
	        <div class="max-w-6xl mx-auto px-4 py-4 flex items-center justify-between">
	            <div class="flex items-center">
	                <i class="fas fa-leaf text-green-500 mr-2"></i>
	                <h1 class="text-xl font-bold text-green-500">Natureza Viva</h1>
	            </div>
	            <nav class="flex space-x-4">
	                <a href="rentals.jsp" class="font-bold text-zinc-700 hover:text-zinc-950">Espaços</a>
	                <a href="closure.jsp" class="font-bold text-zinc-700 hover:text-zinc-950">Fechamento</a>
	                <a href="open-occurrence.jsp" class="font-bold text-zinc-700 hover:text-zinc-950">Ocorrências</a>
	                <a href="sign-out.jsp" class="font-bold text-rose-600 hover:text-rose-800">Sair</a>
	            </nav>
	        </div>
	    </header>
	    
	    <main class="mt-16 flex-grow flex items-center justify-center w-full px-4">
		    <section class="max-w-6xl w-full h-[750px] rounded-lg overflow-y-auto" role="region" aria-labelledby="list-title">
		        <div class="grid gap-4 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 xl:grid-cols-4">
		            <% for (RentReserved r : UserRentService.getInstance().findAllReservedRentals()) { %>
		                <form action="<%= request.getRequestURI() %>" method="post" class="bg-white rounded-lg shadow p-4 flex flex-col justify-between h-full min-h-[300px]">
		                    <div class="flex-grow h-[220px] max-h-[220px] overflow-y-auto">
		                        <h2 class="text-lg font-semibold text-gray-800"><%= r.rent().name() %></h2>
		                        <p class="text-gray-600 mt-2"><%= r.rent().address() + ". " + "Disponível de " + r.rent().initialDatetime() + " à " + r.rent().finalDatetime() + ", " + r.rent().description() %></p>
		                        <p class="text-muted-foreground mt-1 text-sm font-semibold"><%= rentType.get(r.rent().rentType()) %></p>
		                    </div>
		                    <input type="hidden" name="id" value="<%= r.userRentId() %>">
		                    <% if (r.rentStatus().equals(2L)) { %>
	                            <div class="flex gap-2 mt-2">
								    <button name="action" value="approve" class="flex-1 bg-green-500 text-white font-semibold py-2 px-4 rounded hover:bg-green-600 focus:outline-none focus:ring-2 focus:ring-green-400 focus:ring-offset-2 text-center" aria-label="Aprovar reserva do espaço">
								        Aprovar
								    </button>
								    <button name="action" value="recuse" class="flex-1 bg-rose-500 text-white font-semibold py-2 px-4 rounded hover:bg-rose-600 focus:outline-none focus:ring-2 focus:ring-rose-400 focus:ring-offset-2 text-center" aria-label="Recusar reserva do espaço">
								        Recusar
								    </button>
								</div>
		                    <% } else if (r.rentStatus().equals(4L)) { %>
			                    <div class="flex gap-2 mt-2">
			                    	<button name="action" value="finalize" class="flex-1 bg-green-500 text-white font-semibold py-2 px-4 rounded hover:bg-green-600 focus:outline-none focus:ring-2 focus:ring-green-400 focus:ring-offset-2 text-center" aria-label="Aprovar reserva do espaço">
		                                Finalizar
		                            </button>
		                            <button name="action" value="occurrence" class="flex-1 bg-rose-500 text-white font-semibold py-2 px-4 rounded hover:bg-rose-600 focus:outline-none focus:ring-2 focus:ring-rose-400 focus:ring-offset-2 text-center" aria-label="Recursar reserva do espaço">
		                                Ocorrência
		                            </button>
	                           </div>
		                    <% } %>
		                    <span class="mt-2 text-sm text-blue-600 font-semibold"><%= rentStatus.get(r.rentStatus()) %></span>
		                </form>
		            <% } %>
		        </div>
		    </section>
		</main>
		
		<% if (!sucesso.equals("")) { %>
	        <div class="fixed bottom-4 right-4 bg-green-100 border border-green-400 text-green-700 px-4 py-3 rounded shadow-lg" role="alert">
	            <span class="font-bold">Sucesso:</span>
	            <span class="block sm:inline"><%= sucesso %></span>
	        </div>
	    <% } else if (!erro.equals("")) { %>
	        <div class="fixed bottom-4 right-4 bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded shadow-lg" role="alert">
	            <span class="font-bold">Erro:</span>
	            <span class="block sm:inline"><%= erro %></span>
	        </div>
	    <% } %>
	</body>
</html>


