<%@ Page Title="Policy Tech - Demo" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="DocumentComparison.Default" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="head" runat="server">
</asp:Content>


<asp:Content ID="BodyContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
	<input id="txtSessionID" type="hidden" value="<%= Session.SessionID %>" />

	<style>
		.pagination {
			display: inline-block;
		}

		.pagination a {
			color: black;
			float: left;
			padding: 8px 16px;
			text-decoration: none;
			transition: background-color .3s;
			border: 1px solid #ddd;
		}

		.pagination a.active {
			background-color: #4CAF50;
			color: white;
			border: 1px solid #4CAF50;
		}

		.pagination a:hover:not(.active) {
			background-color: #ddd;
		}
	</style>
	<script src="https://cdn.canvasjs.com/canvasjs.min.js"></script>
	<script>
		function getlocalStoragetime(docid) {
			var time = localStorage.getItem('timer1') || "00:00:00",
				parts = time.split(':'),
				hours = +parts[0],
				minutes = +parts[1],
				seconds = +parts[2],
				span = $('#Lastcountup');

			function correctNum(num) {
				return (num < 10) ? ("0" + num) : num;
			}
			var displayTime = correctNum(hours) + ":" + correctNum(minutes) + ":" + correctNum(seconds);
            docid != null && $.ajax({
                type: "POST",
                url: "Default.aspx/GetDocumentSessionData",
                data: '{ docId: "' + docid + '", sessionTime: "' + displayTime +'" }',
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (data) {
                    let sumSeconds = 0;
                    data.d.forEach(time => {
                        let a = time.sessiontime.split(":");
                        let seconds = +a[0] * 60 * 60 + +a[1] * 60 + +a[2];
                        sumSeconds += seconds;
					});
					let time = new Date(sumSeconds * 1000).toISOString().substr(11, 8);
                    span.text(time);					
                },
                failure: function (data) {
                    alert('error');
                }
            });
		}
		function getlocalStoragetime1() {
			var time1 = "00:00:00",
				parts = time1.split(':'),
				hours = +parts[0],
				minutes = +parts[1],
				seconds = +parts[2],
				span1 = $('#countup');

			function correctNum(num) {
				return (num < 10) ? ("0" + num) : num;
			}

			setInterval(function () {
				seconds++;
				if (seconds > 59) {
					minutes++;
					seconds = 0;

					if (minutes > 59) {
						hours++;
						seconds = 0;
						minutes = 0;

						if (hours >= 24) {
							alert("You're logged-in for 24 hours.");
						}
					}
				}
				var displayTime = correctNum(hours) + ":" + correctNum(minutes) + ":" + correctNum(seconds);
				localStorage.setItem('timer1', displayTime);
				span1.text(displayTime);
			}, 1000);
		}
		function getDocumentSessions(docid) {
            var dataPoints = [];
            var datapoints = [
                { y: 79.45, label: "Google" },
                { y: 7.31, label: "Bing" },
                { y: 7.06, label: "Baidu" },
                { y: 4.91, label: "Yahoo" },
                { y: 1.26, label: "Others" }
            ];
            $.ajax({
                type: "POST",
                url: "Default.aspx/GetDocumentSessions",
                data: '{ docId: "' + docid + '"}',
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (data) {
                    data.d.forEach(time => {
                        let a = time.sessiontime.split(":");
                        let seconds = +a[0] * 60 * 60 + +a[1] * 60 + +a[2];
						let time1 = new Date(seconds * 1000).toISOString().substr(11, 8);
						dataPoints.push({
                            y: seconds,
                            label: "Session "+time.sessionid
                        });
                    });
                    var chart = new CanvasJS.Chart("chartContainer", {
                        animationEnabled: true,
                        title: {
                            text: "Document Sessions"
                        },
                        data: [{
                            type: "pie",
                            startAngle: 240,
                            yValueFormatString: "##0\" Sec\"",
                            indexLabel: "{label}",
                            dataPoints: dataPoints
                        }]
                    });
                    chart.render();
                },
                failure: function (data) {
                    alert('error');
                }
            });
            
           
        }
		window.onload = function () {
            const params = new Proxy(new URLSearchParams(window.location.search), {
                get: (searchParams, prop) => searchParams.get(prop),
            });

            getlocalStoragetime(params.docid);
			getlocalStoragetime1();

            getDocumentSessions(params.docid);
            //var datapoints = [
            //    { y: 79.45, label: "Google" },
            //    { y: 7.31, label: "Bing" },
            //    { y: 7.06, label: "Baidu" },
            //    { y: 4.91, label: "Yahoo" },
            //    { y: 1.26, label: "Others" }
            //];

            //var chart = new CanvasJS.Chart("chartContainer", {
            //    animationEnabled: true,
            //    title: {
            //        text: "Document Sessions"
            //    },
            //    data: [{
            //        type: "pie",
            //        startAngle: 240,
            //        yValueFormatString: "##0.00\"%\"",
            //        indexLabel: "{label} {y}",
            //        dataPoints: datapoints
            //    }]
            //});
            //chart.render();
		};



    </script>
	<%--<h1>My Documents</h1>--%>
	<%--<p class="lead margin-top-10">Manage, view and compare Microsoft Word documents.</p>--%>

	<%--<ul id="myTab" class="nav navbar-default nav-tabs margin-bottom-5">
		<li class="active">
			<a href="#MyDocumentsTab" data-toggle="tab">My Documents</a>
		</li>
	</ul>--%>
	<!-- Document Viewer -->
	<div class="modal fade" id="DocumentViewerDialog" tabindex="-1" role="dialog" aria-labelledby="DocumentViewerDialogTitle" aria-hidden="true">
		<div class="modal-dialog modal-lg" style="width: 98%; margin-top: auto;">
			<div class="modal-content" id="DocumentViewerDialogContent">
				<div class="modal-header">
					<%--<div class="row" style="margin-top:-15PX">
						<div class="col-md-4"></div>
						<div class="col-md-4">
							<button id="TopAreaCallbackPanel_ActionsToolbar_ToolbarItem_8151995344ff491cad81de21e2a8a08d" 
								type="button" class="btn btn-primary dropdown-toggle" style="background-color:#3265d7"
								title="Marking as read indicates that you have read and understood the entire content." 
								onclick="DocWizard.DocumentWizard.Navigate('RunWorkflowRule', '8151995344ff491cad81de21e2a8a08d', 'MarkAsRead', '', true)">Mark as Read</button>
							<button id="TopAreaCallbackPanel_ActionsToolbar_ToolbarItem_37b84b63160a453caa35a00f9161c5de" type="button"
								style="background-color:#3265d7"
								class="btn btn-primary dropdown-toggle" title="Copy a link to share" onclick="DocWizard.DocumentWizard.Navigate('RunWorkflowRule', '37b84b63160a453caa35a00f9161c5de', 'Share', '', true)">Share</button>
							<div class="btn-group">
								<button id="TopAreaCallbackPanel_ActionsToolbar_ToolbarItem_MoreActions" type="button" style="background-color:#3265d7"
									class="btn btn-primary dropdown-toggle" title="" onclick="ASPxPopupMenu_Actions_PopUp()" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">More <i class="fas fa-caret-down" style="margin-left: 10px;"></i></button>


								<ul class="dropdown-menu">

									<li><a href="javascript:void(0);" id="spanMenu_c17462310ca44599991433a36fd71c6c" class="dropdown-item" onclick="ASPxPopupMenu_Actions_ItemClick('c17462310ca44599991433a36fd71c6c');">Send Message to Owner</a></li>

								</ul>

							</div>
						</div>
						<div class="col-md-4"></div>
					</div>--%>
					<div class="row">
						<div class="col-lg-4">
							<div class="navbar-header">
								<%--<span id="DocumentViewerDialogTitle1" class="navbar-brand">TutorialsPoint</span>--%>
							</div>
						</div>
						<div class="col-lg-4">
						</div>
						<div class="col-lg-4">
							<%--<button type="button" class="navbar-text navbar-right"
								onclick="closeCurrentTab();">
								<span aria-hidden="true">&times;</span></button>--%>
						</div>
					</div>
					<div class="row">
						<div class="col-lg-8">
							<div class="modal-body">
								<div class="row">
									<div class="col-lg-6">
										<button type="button" id="DocumentViewerDialogTitle" class="btn btn-info" data-toggle="collapse" style="background-color: dimgrey; border-color: dimgrey; width: 100%"
											data-target="#demo">
											Simple collapsible</button>
									</div>
									<div class="col-lg-6">
										<ul id="DocumentViewerPaginationUL" class="nav navbar-nav navbar-left pagination" style="margin:0px">
											<li>
												<a href="#" aria-label="Previous" style="background: #337ab7; color: whitesmoke;">
													<span id="spnTotalPages" aria-hidden="true"></span>
												</a>
											</li>
											
										</ul>
									</div>
								</div>
								<div class="row col-lg-12">
									<div id="demo" class="collapse in" aria-expanded="true">
										<img class="img-responsive center-block" style="width: 100%;"
											src="http://localhost:50465/Temp/temp.png" id="CurrentDocumentPage" />
									</div>
								</div>
							</div>
						</div>
						<div class="col-lg-4">
							
							<div class="row col-lg-14">

								<ul class="nav navbar-nav navbar-left pagination" style="margin-top:12px;">
									<li>
										<a href="#" aria-label="Previous" style="background-color: #337ab7; color: #fff;">Total Session On Document : <span id="Lastcountup">00:00:00</span>
										</a>
									</li>
									<li>
										<a href="#" aria-label="Previous" style="background-color: #337ab7; color: #fff;">Current Session :<span id="countup">00:00:00</span>
										</a>
									</li>
								</ul>
							</div>
							<div class="row col-lg-12">
								<div id="chartContainer" style="height: 370px; width: 100%;"></div>
							</div>
						</div>

						<%--<div id="DocumentViewerSummary"> style="background-color: #3265D7!important"
								Added <span id="DocumentViewerSummaryAdded" class="label label-primary">4</span> ,
                        Deleted <span id="DocumentViewerSummaryDeleted" class="label label-danger">2</span>
							</div>--%>
					</div>
				</div>
			</div>
		</div>
	</div>

	<script src="Default.js"></script>
</asp:Content>
