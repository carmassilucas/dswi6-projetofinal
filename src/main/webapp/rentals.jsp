<%@page import="java.util.List"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.time.LocalDate"%>
<%@page import="dto.ListRentResponse"%>
<%@page import="java.util.Map"%>
<%@page import="entity.Rent"%>
<%@page import="exception.DateRangeException"%>
<%@page import="java.sql.SQLException"%>
<%@page import="exception.RentAreadyExists"%>
<%@page import="service.RentService"%>
<%@page import="dto.CreateRentRequest"%>
<%@page import="java.time.LocalDateTime"%>
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
    
    List<ListRentResponse> rentals = List.of();
    String sucesso = "";
    String erro = "";
    
    if (request.getMethod().equalsIgnoreCase("post")) {
    	String action = request.getParameter("action");
    	
    	if (action == null) {
	    	response.sendRedirect("rentals.jsp");
	    	return;
	    }
		
		try {
			if (action.equals("create")) {
				RentService.getInstance().create(new CreateRentRequest(
		    			request.getParameter("name"),
		    			request.getParameter("address"),
		    			Long.parseLong(request.getParameter("rent_type")),
		    			LocalDateTime.parse(request.getParameter("initial_datetime")),
		    			LocalDateTime.parse(request.getParameter("final_datetime")),
		    			request.getParameter("description")
				));
				sucesso = "Espaço cadastrado com sucesso!";
				rentals = RentService.getInstance().findAll();
			} else if (action.equals("filter")) {
				rentals = RentService.getInstance().filter(
						request.getParameter("filter_address"),
						request.getParameter("filter_initial_date"),
		    			request.getParameter("filter_final_date")
				);
			} else if (action.equals("clean")) {
				response.sendRedirect("rentals.jsp");
		    	return;
			}
		} catch(RentAreadyExists | DateRangeException e) {
		    erro = e.getMessage();
		}
	} else {
		rentals = RentService.getInstance().findAll();
	}
    
    Map<Long, String> rentType = Map.of(1L, "Auditório", 2L, "Salão de festas");
    
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
	    <title>Gerenciar espaços | Natureza Viva</title>
	    <script src="https://cdn.tailwindcss.com"></script>
	    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
	</head>
	<body class="bg-gray-100 flex flex-col items-center justify-center min-h-screen">
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
	        <div class="max-w-6xl w-full grid grid-cols-1 md:grid-cols-10 gap-6">
	            <form action="<%= request.getRequestURI() %>" method="post" class="bg-white p-6 rounded-lg shadow-md space-y-4 md:col-span-3" role="form" aria-labelledby="form-title">
	                <h3 id="form-title" class="text-xl font-bold text-center text-green-500 mb-4">Disponibilizar espaço</h3>
	
	                <div class="mb-4">
	                    <label for="name" class="block text-sm font-medium text-gray-700">Nome do espaço</label>
	                    <input type="text" id="name" name="name" class="mt-2 w-full p-2 border border-gray-300 rounded-lg" placeholder="Nome do espaço" required aria-label="Nome do espaço" />
	                </div>
	
	                <div class="mb-4">
	                    <label for="address" class="block text-sm font-medium text-gray-700">Endereço</label>
	                    <input type="text" id="address" name="address" class="mt-2 w-full p-2 border border-gray-300 rounded-lg" placeholder="Endereço do espaço" required aria-label="Endereço do espaço" />
	                </div>
	
	                <div class="mb-4">
	                    <label for="rent_type" class="block text-sm font-medium text-gray-700">Tipo do espaço</label>
	                    <select id="rent_type" name="rent_type" class="mt-2 w-full p-2 border border-gray-300 rounded-lg" required aria-label="Tipo do espaço">
	                        <option value="" disabled selected>Selecione um tipo</option>
	                        <option value="1">Auditório</option>
	                        <option value="2">Salão de Festas</option>
	                    </select>
	                </div>
	
	                <div class="mb-4">
	                    <label for="initial_datetime" class="block text-sm font-medium text-gray-700">Data inicial</label>
	                    <input type="datetime-local" id="initial_datetime" name="initial_datetime" class="mt-2 w-full p-2 border border-gray-300 rounded-lg" required aria-label="Data e hora inicial" />
	                </div>
	
	                <div class="mb-4">
	                    <label for="final_datetime" class="block text-sm font-medium text-gray-700">Data final</label>
	                    <input type="datetime-local" id="final_datetime" name="final_datetime" class="mt-2 w-full p-2 border border-gray-300 rounded-lg" required aria-label="Data e hora final" />
	                </div>
	
	                <div class="mb-4">
	                    <label for="description" class="block text-sm font-medium text-gray-700">Observações</label>
	                    <textarea id="description" name="description" class="mt-2 h-32 max-h-32 w-full p-2 border border-gray-300 rounded-lg" placeholder="Fale um pouco sobreo espaço..." aria-label="Observações adicionais"></textarea>
	                </div>
	
	                <div class="flex justify-center">
	                    <button name="action" value="create" type="submit" class="w-full bg-green-500 hover:bg-green-600 text-white font-bold py-2 px-4 rounded-md focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-green-500" aria-label="Cadastrar espaço">Cadastrar Espaço</button>
	                </div>
	            </form>
	
	            <section class="space-y-4 md:col-span-7 h-[750px] rounded-lg overflow-y-auto" role="region" aria-labelledby="list-title">
				    <form action="<%= request.getRequestURI() %>" method="post" class="w-full grid grid-cols-1 sm:grid-cols-[1fr_1fr_auto] gap-4 items-center">
					    <div>
					        <label for="filter_initial_date" class="block text-sm font-medium text-gray-700">Data de início</label>
					        <input type="date" id="filter-initial-date" name="filter_initial_date" class="w-full p-2 border border-gray-300 rounded-lg placeholder-gray-500 focus:border-green-500 focus:ring focus:ring-green-200 focus:ring-opacity-50">
					    </div>
					    
					    <div>
					        <label for="filter_final_date" class="block text-sm font-medium text-gray-700">Data de fim</label>
					        <input type="date" id="filter-final-date" name="filter_final_date" class="w-full p-2 border border-gray-300 rounded-lg placeholder-gray-500 focus:border-green-500 focus:ring focus:ring-green-200 focus:ring-opacity-50">
					    </div>
					    
					    <div class="flex flex-col gap-1">
					        <label for="filter_address" class="text-sm font-medium text-gray-700">Nome do espaço</label>
					        <div class="flex gap-2">
					            <input type="text" id="filter-address" name="filter_address" class="w-full p-2 border border-gray-300 rounded-lg placeholder-gray-500 focus:border-green-500 focus:ring focus:ring-green-200 focus:ring-opacity-50" placeholder="Digite o nome">
					            
					            <button name="action" value="filter" type="submit" class="bg-green-500 text-white font-semibold p-2 w-12 h-12 flex items-center justify-center rounded-lg hover:bg-green-600 focus:outline-none focus:ring-2 focus:ring-green-500 focus:ring-offset-2" aria-label="Aplicar filtros">
					                <i class="fas fa-search"></i>
					            </button>
					        </div>
					    </div>
					</form>
		
		            <div class="grid gap-4 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-2 xl:grid-cols-3">
		                <% for (ListRentResponse r : rentals) { %>
		                    <div class="bg-white rounded-lg shadow p-4 flex flex-col justify-between h-full">
		                        <div class="max-h-[180px] overflow-y-auto">
		                            <h2 class="text-lg font-semibold text-gray-800"><%= r.rent().name() %></h2>
		                            <p class="text-gray-600 mt-2"><%= r.rent().address() + ". " + "De " + r.rent().initialDatetime() + " à " + r.rent().finalDatetime() + ", " + r.rent().description() %></p>
		                            <p class="text-muted-foreground mt-1 text-sm"><%= rentType.get(r.rent().rentType()) %></p>
		                        </div>
		                        <% if(r.isReserved()) { %>
		                            <a class="mt-4 bg-gray-400 text-gray-300 font-semibold py-2 w-full rounded cursor-not-allowed text-center opacity-60 pointer-events-none focus:outline-none" aria-label="Editar aluguel - botão desativado">
		                                Editar
		                            </a>
		                        <% } else if (r.isConclude()) { %>
		                            <span class="mt-4 text-green-500 font-semibold cursor-not-allowed text-center py-2" aria-label="Concluído">
		                                Concluído
		                            </span>
		                        <% } else { %>
		                            <a href="<%= "alter-rent.jsp?id=" + r.rent().id() %>" class="mt-4 bg-blue-500 text-white font-semibold py-2 w-full rounded hover:bg-blue-600 focus:outline-none focus:ring-2 focus:ring-blue-400 focus:ring-offset-2 text-center" aria-label="Editar aluguel">
		                                Editar
		                            </a>
		                        <% } %>
		                    </div>
		                <% } %>
		            </div>
		        </section>
	        </div>
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